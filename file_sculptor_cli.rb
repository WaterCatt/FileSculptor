# file_sculptor_cli.rb
require_relative 'file_sculptor'
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby file_sculptor_cli.rb -a ACTION -p PATH [options]"

  opts.on("-a", "--action ACTION", "Действие: rename или organize") do |action|
    options[:action] = action
  end

  opts.on("-p", "--path PATH", "Путь к директории") do |path|
    options[:path] = path
  end

  opts.on("-r", "--recursive", "Обрабатывать вложенные директории") do
    options[:recursive] = true
  end

  opts.on("-d", "--dry-run", "Показать действия, не изменяя файлы") do
    options[:dry_run] = true
  end

  opts.on("--rule RULE", "Правило организации (extension, first_letter, date)") do |rule|
    options[:rule] = rule.downcase
  end

  opts.on("-h", "--help", "Показать помощь") do
    puts opts
    exit
  end
end.parse!

if options[:action].nil? || options[:path].nil?
  puts "Отсутствуют обязательные параметры: action, path"
  puts "Usage: ruby file_sculptor_cli.rb -a ACTION -p PATH [options]"
  exit
end

sculptor = FileSculptor.new(options[:path], recursive: options[:recursive], dry_run: options[:dry_run])

case options[:action]
when "rename"
  sculptor.rename_files
when "organize"
  rule = options[:rule] || 'extension'
  sculptor.organize_files do |path|
    case rule
    when 'extension'
      ext = File.extname(path).delete('.').capitalize
      "Organized/#{ext}"
    when 'first_letter'
      first = File.basename(path)[0].upcase
      "Organized/FirstLetter/#{first}"
    when 'date'
      date = File.mtime(path).strftime('%Y-%m-%d')
      "Organized/Date/#{date}"
    else
      ext = File.extname(path).delete('.').capitalize
      "Organized/#{ext}"
    end
  end
else
  puts "Неизвестное действие: #{options[:action]}"
end
