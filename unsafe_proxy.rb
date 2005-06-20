# MIDI SCRIPTER
# Copyright (c) 2005 Emanuel Borsboom
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the 
# "Software"), to deal in the Software without restriction, including 
# without limitation the rights to use, copy, modify, merge, publish, 
# distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the 
# following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
# NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
# USE OR OTHER DEALINGS IN THE SOFTWARE.
# ------------------------------------------------------------------------------------
#
# UnsafeProxy class, which allows you to call code that is running at a lower $SAFE level.
#

require 'thread'

class UnsafeProxy

	def initialize(obj, *methods)
                @obj = obj
		@methods = methods
		if (@methods.length == 0)
			@methods = obj.class.public_instance_methods(false)
			@methods.collect! { |x| x.intern }
		end

		thr = Thread.new do
			# Create instance variables at safe level 3 so they are tainted so that safe level 4 code can use them
			$SAFE = 3
                        @call_queue = Queue.new
                        @result_queue = Queue.new
		end
		thr.join
		self.taint # Taint self so that safe level 4 code can use me
		
		@thread = Thread.new do
                        #puts "proxy starting"
                        
                        while true
                                # "proxy waiting"
                                meth, args = @call_queue.pop
                                #puts "proxy meth=#{meth} args=#{args}"
                                if meth == '__DESTOY__'
                                        #puts "proxy exiting"
                                        Thread.exit
                                end
                                to_push = nil
                                begin
                                        if !@methods.include? meth
                                                raise SecurityError, "No permission to call method '" + @meth.to_s + "'", caller
                                        end
                                        result = @obj.send(meth, *args)
                                        #puts "proxy pushing result"
                                        to_push = ['result', result]
                                rescue Exception => excep
                                        #puts "proxy pushing exception #{excep}"
                                        to_push = ['exception', excep]
                                ensure
                                        if to_push == nil
                                                to_push = ['exception', Exception.new("This shouldn't ever happen")]
                                        end
                                        @result_queue.push to_push
                                end
                        end
                end
	end
        
        def destroy
                @call_queue.push ['__DESTOY__', []]
        end
	
	def method_missing(meth, *args)
                #puts "method_missing pushing #{meth} #{args}"
                @call_queue.push [meth, args]
                #puts "method_missing waiting"
                type, value = @result_queue.pop
                #puts "method_missing type=#{type}"
                if type == "exception"
                        #puts "method_missing raising exception"
                        raise value, value.to_s, caller[2..-1]
                else
                        #puts "method_missing returning value"
                        return value
                end
	end

end
