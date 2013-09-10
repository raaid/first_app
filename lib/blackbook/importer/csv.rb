require 'csv'

##
# Imports contacts from a CSV file

class Blackbook::Importer::Csv < Blackbook::Importer::Base

  DEFAULT_COLUMNS = [:name,:email,:misc]

  ##
  # Matches this importer to a file that contains CSV values

  def =~(options)
    options && options[:file].respond_to?(:open) ? true : false
  end

  ##
  # fetch_contacts! implementation for this importer

  def fetch_contacts!
    headers = IO.readlines(options[:file].path, :limit => 1)
    columns = to_columns(headers.first)

    has_own_headers = (columns.first == :name || columns.first == :fname || columns.first.to_s == '"Title"')
    lines = CSV.read(options[:file].path, :headers => has_own_headers,
                                    :quote_char => '"', :col_sep =>',', :row_sep =>:auto)
    columns = DEFAULT_COLUMNS.dup unless has_own_headers

    contacts = Array.new
    lines.each do |vals|
      next if vals.empty?
      if (columns.first == :fname)
        contacts << outlook_to_hash(vals)
      else
        # A bug fix here - if it has headers then the vals are structured objects that to_hash can't accept.
        contacts << to_hash(columns, has_own_headers ? vals.fields : vals)
      end
    end

    contacts
  end

  def to_hash(cols, vals) # :nodoc:
    h = Hash.new
    cols.each do |c|
      h[c] = (c == cols.last) ? vals.join(',') : vals.shift
    end
    h
  end

  def outlook_to_hash(vals) # :nodoc:
    h = Hash.new
    # this is so ugly - mc
    h[:name] = vals["First Name"]
    h[:lname] = vals["Last Name"]
    h[:email] = vals["E-mail Address"]
    h[:birthday] = vals["Birthday"]
    h[:gender] = vals["Gender"]
    h[:address] = vals["Address"]
    h[:city] = vals["City"]
    h[:country] = vals["Country"]
    h
  end

  def to_columns(line) # :nodoc:
    columns = Array.new
    tags = line.split(',')
    # deal with "Name,E-mail..." oddity up front
    if tags.first =~ /^name$/i
      tags.shift
      columns << :name
      if tags.first =~ /^e.?mail/i # E-mail or Email
        tags.shift
        columns << :email
      end
    elsif tags.first =~ /^first.?name$/i # tag firstname for outlook format
        columns << :fname
    end
    tags.each{|v| columns << v.strip.to_sym}
    columns
  end

  Blackbook.register(:csv, self)
end
