require 'fileutils'

class FileSculptor
  def initialize(path, recursive: false, dry_run: false)
    @path = path
    @recursive = recursive
    @dry_run = dry_run
  end

  def rename_files
    pattern = @recursive ? "**/*" : "*"
    files = Dir.glob(File.join(@path, pattern)).select { |f| File.file?(f) }

    puts "Найдено файлов для переименования: #{files.size}"
    files.each do |file_path|
      dirname = File.dirname(file_path)
      ext = File.extname(file_path)
      base = File.basename(file_path, ext)

      next if base.nil? || ext.nil? || base.empty?

      new_name = "#{base.downcase.gsub(/\s+/, '_')}#{ext.downcase}"
      new_path = File.join(dirname, new_name)

      if File.identical?(file_path, new_path)
        puts "Пропускаем #{file_path}, имя уже в нужном формате"
        next
      end

      if File.exist?(new_path)
        puts "Пропускаем #{file_path}, файл #{new_path} уже существует"
        next
      end

      puts "#{@dry_run ? '[СУХОЙ РЕЖИМ] ' : ''}Переименование: #{file_path} -> #{new_path}"
      FileUtils.mv(file_path, new_path) unless @dry_run
    end
  end

  def organize_files(rule = 'extension')
    pattern = @recursive ? "**/*" : "*"
    files = Dir.glob(File.join(@path, pattern)).select { |f| File.file?(f) }

    puts "Найдено файлов для организации: #{files.size}"
    files.each do |file_path|
      case rule
      when 'extension'
        ext = File.extname(file_path).delete('.').capitalize
        ext = "NoExt" if ext.empty?
        target_dir = File.join(@path, 'Organized', ext)
      else
        puts "Неизвестное правило организации: #{rule}"
        next
      end

      FileUtils.mkdir_p(target_dir) unless File.directory?(target_dir)

      file_name = File.basename(file_path)
      target_path = File.join(target_dir, file_name)

      if File.exist?(target_path)
        puts "Пропускаем #{file_path}, файл #{target_path} уже существует"
        next
      end

      puts "#{@dry_run ? '[СУХОЙ РЕЖИМ] ' : ''}Перемещение: #{file_path} -> #{target_path}"
      FileUtils.mv(file_path, target_path) unless @dry_run
    end
  end
end