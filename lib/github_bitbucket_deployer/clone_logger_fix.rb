require 'git'

# Patch ruby-git to support logger for Git.clone
# See https://github.com/schacon/ruby-git/issues/208
module CloneLoggerFix
  module ClassMethods
    def clone(repository, name, opts = {})
      lib = ::Git::Lib.new(nil, opts[:log])
      clone_opts = lib.clone(repository, name, opts)
      new(clone_opts.merge(log: opts[:log]))
    end
  end

  def self.prepended(base)
    class << base
      prepend ClassMethods
    end
  end
end

::Git::Base.prepend(CloneLoggerFix)
