# This checks spaces after the . selector
class Test1
  attr_reader :pattern, :message

  def initialize
    @pattern = /\. [a-zA-Z0-9-]/
    @message = 'Test1 There should not be an empty space after calling a selector'
  end
end

# This checks spaces after the #  selector
class Test2
  attr_reader :pattern, :message

  def initialize
    @pattern = /\# [a-zA-Z0-9-]/
    @message = 'Test2 There should not be an empty space after calling a selector'
  end
end

# This checks for no spaces before opening bracket when using . selector
class Test3
  attr_reader :pattern, :message

  def initialize
    @pattern = /\.[a-zA-Z0-9-]+\{/
    @message = 'Test3 There should be an empty space before the opening bracket'
  end
end

# This checks for no spaces before opening bracket when using # selector
class Test4
  attr_reader :pattern, :message

  def initialize
    @pattern = /\#[a-zA-Z0-9-]+\{/
    @message = 'Test4 There should be an empty space before the opening bracket'
  end
end

# This checks for anything but white spaces inside the brackets when using a . selector
class Test5
  attr_reader :pattern, :message

  def initialize
    @pattern = /\.[a-zA-Z0-9-]+\s{\s*}/
    @message = 'Test5 There is nothing inside the selector brackets'
  end
end

# This checks for anything but white spaces inside the brackets when using a # selector
class Test6
  attr_reader :pattern, :message

  def initialize
    @pattern = /\#[a-zA-Z0-9-]+\s{\s*}/
    @message = 'Test6 There is nothing inside the selector brackets'
  end
end

# This checks for spaces before the selector name and no space after the selector name.
class Test7
  attr_reader :pattern, :message

  def initialize
    @pattern = /\. [a-zA-Z0-9-]+\{/
    @message = 'Test7 There should be an empty space before the opening bracket, no spaces before the selector name'
  end
end

# This checks for spaces before the selector name and no space after the # selector name.
class Test8
  attr_reader :pattern, :message

  def initialize
    @pattern = /\# [a-zA-Z0-9-]+\{/
    @message = 'There should be an empty space before the opening bracket, no spaces before the selector name'
  end
end
