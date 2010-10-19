$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'shrk'
require 'mocha'
include Mocha::API
require 'spec'
require 'spec/autorun'

require 'ruby-debug'

require 'fakeweb'

Spec::Runner.configure do |config|
  
end


