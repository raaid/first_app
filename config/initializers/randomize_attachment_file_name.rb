module Paperclip
    module ClassMethods
      def randomizes_attachment_file_name name
        before_post_process :"randomize_#{name}_file_name"
        define_method :"randomize_#{name}_file_name" do |*args|
          #self.send(name).queue_existing_files_for_delete
          extension = File.extname(self.send(:"#{name}_file_name"))
          self.send(name).instance_write(:file_name,
"#{Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )[0, 14]}#{extension.downcase}")
        end
      end
    end
  end