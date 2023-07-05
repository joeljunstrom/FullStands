class ApplicationMailbox < ActionMailbox::Base
  routing(/\A[A-z]*@ebiljett.nu\z/i => :somewhere)
end
