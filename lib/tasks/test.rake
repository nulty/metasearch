desc "Opening and mainpulating file contents"

task :filemanip => :environment do
	

	queries = File.open(Rails.root.join "lib/assets/queries").each_line do |line|
	
		puts line
		puts "Thats a line!"
		sleep 10
	end
	
	
	
end
