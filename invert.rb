#!/usr/bin/env ruby

class Invertable
  require 'pathname'

  attr_accessor :name, :image, :images, :prefix, :location, :path, :kill_process, :launch_process

  class << self
    def invert name, image = nil, prefix = nil
      invertable        = new
      invertable.name   = name
      invertable.image  = image
      invertable.prefix = prefix

      yield invertable if block_given?

      if invertable.exists? then
        puts "#{name}: found, inverting"
        invertable.invert
        invertable.relaunch
      else
        warn "#{name}: not found, skipping"
      end
    end
  end

  def full_path file
    if prefix then
      self.send(prefix).join file
    elsif location
      Pathname.new(location).join file
    else
      file
    end
  end

  def resources
    path.join '/Contents/Resources', location.to_s
  end

  def library
    path.join '/Contents/Library', location.to_s
  end

  def kill_process
    @kill_process || name
  end

  def launch_process
    @launch_process || path
  end

  def exists?
    !path.nil?
  end

  def path
    @path ||= get_path
  rescue TypeError => error
    warn error
    nil
  end

  def home
    @@home ||= Pathname.new('~').expand_path
  end

  def invert
    (images + [image]).compact.each do |i|
      system *%W{sudo convert -negate #{full_path i} #{full_path i}}

      if not $?.success?
        abort "    try: brew install imagemagick --with-libtiff"
      end
    end
  end

  def relaunch process = name
    kill process
    open
  end

  def kill
    system 'killall', kill_process
  end

  def open
    system 'open', launch_process
  end
end

class Pane < Invertable
  def get_path file = name
    new_path = "#{home}/Library/PreferencePanes/#{file}.prefPane"
    new_path if File.directory? new_path
  end
end

class App < Invertable
  def get_path file = name
    new_path = "/Applications/#{file}.app"
    [new_path, home + new_path].select{|p| File.directory? p }
  end
end

App.invert '1Password', 'menubar-icon.tiff', :resources do |app|
  app.location     = 'LoginItems/2BUA8C4S2C.com.agilebits.onepassword-osx-helper.app/Contents/Resources'
  app.kill_process = '2BUA8C4S2C.com.agilebits.onepassword-osx-helper'
end

App.invert 'BitTorrent Sync' do |app|
  app.images = Dir[app.resources.join "trayIcon_*"]
end

App.invert 'Caffeine' do |app|
  app.images = Dir["/Applications/Caffeine.app/Contents/Resources/*.png"]
end

App.invert 'Crashlytics', 'image.status-item.tiff', :resources

App.invert 'CrashPlan.app/Contents/Resources/CrashPlan menu bar', nil, :resources do |app|
  app.images = %w{
  cp_status_active_anim_dots1 cp_status_active_anim_dots2 cp_status_active_anim_dots3 cp_status_active_anim_dots4
  cp_status_active_anim_dots5 cp_status_active_anim_dots6 cp_status_active_anim_dots7 cp_status_active_anim_dots8
  cp_status_active_anim_dots9 cp_status_active_anim_dots10 cp_status_active_anim_dots11 cp_status_active_anim_dots12
  cp_status_active_anim_dots13 cp_status_active_anim_dots14 cp_status_active_anim_dots15 cp_status_active_anim_dots16
  cp_status_active_anim_dots17 cp_status_active_anim_dots18 cp_status_active_anim_dots19 cp_status_active_anim_dots20
  cp_status_active_anim_dots21 cp_status_alert_dots dots_cp_status_active_anim0 dots_cp_status_active_anim1
  dots_cp_status_active_anim2 dots_cp_status_active_anim3 dots_cp_status_active_anim4 dots_cp_status_active_anim5
  dots_cp_status_active_anim6 dots_cp_status_active_anim7 dots_cp_status_active_anim8 dots_cp_status_active_anim9
  dots_cp_status_active_anim10 dots_cp_status_active_anim11 dots_cp_status_active_anim12 dots_cp_status_active_anim13
  dots_cp_status_active_anim14 dots_cp_status_active_anim15 dots_cp_status_active_anim16 dots_cp_status_active_anim17
  dots_cp_status_active_anim18 dots_cp_status_active_anim19 dots_cp_status_active_anim20 dots_cp_status_active_anim21
  dots_cp_status_complete_alert dots_cp_status_complete dots_cp_status_gray dots_cp_status_paused
  dots_cp_status_safe_alert dots_cp_status_safe dots_cp_status_severe_alert dots_cp_status_severe
  dots_cp_status_warning_alert dots_cp_status_warning gradient_cp_status_active_anim0 gradient_cp_status_active_anim1
  gradient_cp_status_active_anim2 gradient_cp_status_active_anim3 gradient_cp_status_active_anim4
  gradient_cp_status_active_anim5 gradient_cp_status_active_anim6 gradient_cp_status_active_anim7
  gradient_cp_status_active_anim8 gradient_cp_status_active_anim9 gradient_cp_status_active_anim10
  gradient_cp_status_active_anim11 gradient_cp_status_active_anim12 gradient_cp_status_active_anim13
  gradient_cp_status_active_anim14 gradient_cp_status_active_anim15 gradient_cp_status_active_anim16
  gradient_cp_status_active_anim17 gradient_cp_status_active_anim18 gradient_cp_status_active_anim19
  gradient_cp_status_active_anim20 gradient_cp_status_active_anim21 gradient_cp_status_active_anim22
  gradient_cp_status_active_anim23 gradient_cp_status_active_anim24 gradient_cp_status_active_anim25
  gradient_cp_status_active_anim26 gradient_cp_status_complete_alert gradient_cp_status_complete
  gradient_cp_status_gray gradient_cp_status_paused gradient_cp_status_safe_alert gradient_cp_status_safe
  gradient_cp_status_severe_alert gradient_cp_status_severe gradient_cp_status_warning_alert gradient_cp_status_warning
  no_animation_cp_status_active_anim0 no_animation_cp_status_complete_alert no_animation_cp_status_complete
  no_animation_cp_status_paused no_animation_cp_status_safe_alert no_animation_cp_status_safe
  no_animation_cp_status_severe_alert no_animation_cp_status_severe no_animation_cp_status_warning_alert
  no_animation_cp_status_warning
  }.map{|i| "#{i}.png" }

  app.kill_process = 'CrashPlan menu bar'
end

App.invert 'GrabBox', nil, :resources do |app|
  app.images = %w{
    menuicon-animation-1 menuicon-animation-2 menuicon-animation-3 menuicon-animation-4
    menuicon-animation-5 menuicon-animation-6 menuicon-animation-7 menuicon-animation-8 menuicon
  }.map{|i| "#{i}.tiff"}
end

App.invert 'Google Drive', nil, :resources do |app|
  app.images = Dir["/Applications/Google Drive.app/Contents/Resources/mac-*.png"]
end

Invertable.invert 'Hangouts' do |app|
  app.path = app.home.join "/Library/Application\\ Support/Google/Chrome/Default/Extensions/nckgahadagoaajjgafhacjanaoiihapd/"
  app.launch_process 'Google\ Chrome'

  # I get the impression that this section can be further improved
  current_hangouts_version = `\ls #{app.path} | tail -1`.strip
  prefix = "#{app.path}#{current_hangouts_version}/images_4/presence/"

  app.images = `\ls #{app.path} | grep "mac"`.split("\n").map{|f| "#{prefix}#{filename}" }
end

Pane.invert 'HazelHelper', 'HazelStatusAlt.tiff', :resources do |app|
  path = app.home.join '/Library/PreferencePanes/Hazel.prefPane/Contents/Resources/HazelHelper.app'
  app.path           = path
  app.launch_process = path
end

App.invert 'Radium', nil, :resources do |app|
  app.images = %w{
    menubar_icon_busy_1 menubar_icon_busy_2 menubar_icon_busy_3
    menubar_icon_busy_4 menubar_icon_busy_5 menubar_icon_busy_6
    menubar_icon_disabled menubar_icon_pressed menubar_icon_regular
    menubar_icon_success
  }.map{|i| "#{i}.tiff"}
end

App.invert 'TestFlight', 'tf-menubar-icon.png', :resources  do |app|
  app.kill_process 'TestFlightHelper'
end

App.invert 'Tomighty.app', 'status-normal.tiff', :resources

Pane.invert 'TVShowsHelper', nil, :resources do |app|
  path = app.home.join '/Library/PreferencePanes/TVShows.prefPane/Contents/Resources/TVShowsHelper.app'
  app.path           = path
  app.launch_process = path
  app.images = Dir[app.path.join 'Contents/Resources/*.png']
end

App.invert 'Window Magnet' do |app|
  origin_dark  = app.resources.join 'StatusIcon.tiff'
  origin_light = app.resources.join 'StatusIconClicked.tiff'
  tmp = app.resources.join 'StatusIcon.tmp'

  system "sudo mv #{origin_dark} #{tmp}"
  system "sudo mv #{origin_light} #{origin_dark}"
  system "sudo mv #{tmp} #{origin_light}"
end
