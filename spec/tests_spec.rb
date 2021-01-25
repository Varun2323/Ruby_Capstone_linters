require_relative '../lib/error_checkers'
require_relative '../lib/linter_logic'

describe Check do
  describe '#start' do
    subject(:check_start) { described_class.new }
    let(:file) { instance_double(File) }

    it 'sends each_line' do
      expect(file).to receive(:each_line)
      check_start.start(file)
    end

    context 'when file has 1 line' do
      it 'calls check_line once' do
        expect(check_start).to receive(:check_line).once
        file = StringIO.new('1')
        check_start.start(file)
      end
    end

    context 'when file has 3 lines' do
      it 'calls check_line 3 times' do
        expect(check_start).to receive(:check_line).exactly(3).times
        file = StringIO.new("1\n2\n3")
        check_start.start(file)
      end
    end
  end

  describe '#create_buffer' do
    subject(:check_buffer) { described_class.new }

    it 'creates a new StringScanner with a line of string' do
      expect(StringScanner).to receive(:new).with('this is a string line')
      line = 'this is a string line'
      check_buffer.send(:create_buffer, line)
    end
  end

  describe '#check_line' do
    subject(:line_count) { described_class.new }
    let(:buffer) { instance_double(StringScanner) }

    before do
      allow(line_count).to receive(:match_check).and_return(false)
    end

    it 'adds 1 to @line_number' do
      call_checkline = proc { line_count.send(:check_line, buffer) }
      line_number = proc { line_count.instance_variable_get(:@line_number) }
      expect(&call_checkline).to change(&line_number).by(1)
    end

    context 'when an error is detected in a line by all 3 checkers' do
      subject(:checks_line) { described_class.new }

      before do
        allow(checks_line).to receive(:match_check).and_return(true, true, true)
        allow($stdout).to receive(:puts)
        allow(buffer).to receive(:scan_until)
        allow(checks_line).to receive(:error_message)
        allow(buffer).to receive(:reset)
      end

      it 'changes @line_errors to true' do
        checks_line.send(:check_line, buffer)
        line_errors = checks_line.line_errors
        expect(line_errors).to be_truthy
      end
    end

    context 'when an error is detected in a line by two checkers' do
      subject(:checks_line) { described_class.new }

      before do
        allow(checks_line).to receive(:match_check).and_return(false, true, true)
        allow($stdout).to receive(:puts)
        allow(buffer).to receive(:scan_until)
        allow(checks_line).to receive(:error_message)
        allow(buffer).to receive(:reset)
      end

      it 'changes @line_errors to true' do
        checks_line.send(:check_line, buffer)
        line_errors = checks_line.line_errors
        expect(line_errors).to be_truthy
      end
    end

    context 'when an error is detected in a line by one checker' do
      subject(:checks_line) { described_class.new }

      before do
        allow(checks_line).to receive(:match_check).and_return(false, false, true)
        allow($stdout).to receive(:puts)
        allow(buffer).to receive(:scan_until)
        allow(checks_line).to receive(:error_message)
        allow(buffer).to receive(:reset)
      end

      it 'changes @line_errors to true' do
        checks_line.send(:check_line, buffer)
        line_errors = checks_line.line_errors
        expect(line_errors).to be_truthy
      end
    end
  end

  describe '#match_check' do
    subject(:check_pattern) { described_class.new }

    context 'when there are errors in the analyzed code' do
      let(:buffer) { StringScanner.new('. h1-class {') }

      context 'when there is a match leaving a space after the . selector: /\. [a-zA-Z0-9-]/' do
        it 'returns a truthy value' do
          pattern = /\. [a-zA-Z0-9-]/
          result = check_pattern.send(:match_check, buffer, pattern)
          expect(result).to be_truthy
        end
      end

      context 'when there is a match leaving a space after the # selector: /\# [a-zA-Z0-9-]/' do
        let(:buffer) { StringScanner.new('# p-id {') }
        it 'returns a truthy value' do
          pattern = /\# [a-zA-Z0-9-]/
          result = check_pattern.send(:match_check, buffer, pattern)
          expect(result).to be_truthy
        end
      end

      context 'when there are no spaces after the selector name: /\.[a-zA-Z0-9-]+\{/' do
        let(:buffer) { StringScanner.new('.h1-class{') }
        it 'returns a truthy value' do
          pattern = /\.[a-zA-Z0-9-]+\{/
          result = check_pattern.send(:match_check, buffer, pattern)
          expect(result).to be_truthy
        end
      end
    end

    context 'when there is no match for any pattern using .h1-class { color:red}' do
      let(:buffer) { StringScanner.new('.h1-class { color:red}') }

      it 'does not return a truthy value for /\. [a-zA-Z0-9-]/' do
        pattern = /\. [a-zA-Z0-9-]/
        result = check_pattern.send(:match_check, buffer, pattern)
        expect(result).to_not be_truthy
      end

      it 'does not return a truthy value for /\.[a-zA-Z0-9-]+\{/' do
        pattern = /\.[a-zA-Z0-9-]+\{/
        result = check_pattern.send(:match_check, buffer, pattern)
        expect(result).to_not be_truthy
      end

      it 'does not return a truthy value for /\.[a-zA-Z0-9-]+\s{\s*}/' do
        pattern = /\.[a-zA-Z0-9-]+\s{\s*}/
        result = check_pattern.send(:match_check, buffer, pattern)
        expect(result).to_not be_truthy
      end
    end
  end

  describe '#error_message' do
    subject(:check_message) { described_class.new }
    let(:buffer) { StringScanner.new('. h1-class {') }

    it 'returns a message indicating line number, position, and error message' do
      expected_message = "Warning in Line 1, Position 3: '. h' => "\
      'Test1 There should not be an empty space after calling a selector'
      msg = 'Test1 There should not be an empty space after calling a selector'
      check_message.instance_variable_set(:@line_number, 1)
      buffer.scan_until(/\. [a-zA-Z0-9-]/)
      result = check_message.send(:error_message, buffer, msg)
      expect(result).to eq(expected_message)
    end
  end
end
