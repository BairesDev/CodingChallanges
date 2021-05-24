# frozen_string_literal: true

this = Pathname(File.realpath(__FILE__))
Dir.glob("#{__dir__}/#{this.basename.to_s.sub(this.extname, '')}/*.rb").sort.each(&method(:require))
