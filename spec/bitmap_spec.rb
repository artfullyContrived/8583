# encoding: binary
#

describe ISO8583, '::Bitmap' do
	it 'creates an empty bitmap.' do
		b = nil
		expect {b = ISO8583::Bitmap.new}.not_to raise_error
		expect(b.to_s.size).to eq(64)

		b.set(112)

		expect(b.to_s.size).to eq(128)
		expect(b.to_s).to eq('10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000')

		b.unset(112)

		5.step(20,2) {|i| b.set(i) }

		expect(b.to_s.size).to eq(64)
		expect(b.to_s).to eq("0000101010101010101000000000000000000000000000000000000000000000")

		expect(b[5]).to  eq(true)
		expect(b[7]).to  eq(true)
		expect(b[11]).to eq(true)
		expect(b[12]).to eq(false)
		expect(b[99]).to eq(false)
	end

	context 'Bitmap boundaries' do
		it 'fails if an out of bound bit is set.' do
			b = ISO8583::Bitmap.new

			expect { b.set rand(129..1000) }.to raise_error ISO8583::ISO8583Exception
			expect { b.set rand(-100..-1) }.to raise_error ISO8583::ISO8583Exception
			expect { b.set 1 }.to raise_error ISO8583::ISO8583Exception
		end
	end

	context 'Parsing bitmaps' do
		it 'parses a 64 bit bitmap.' do
			# 0000000001001001001001001001001001001001001001001001001001000000
			# generated by: 10.step(60,3) {|i| mp.set(i)}

			b = ISO8583::Bitmap.new "\x00\x49\x24\x92\x49\x24\x92\x40"

			10.step(60,3) do|i| 
				expect(b[i]).to   eq(true)
				expect(b[i+i]).to eq(false)
			end
		end

		it 'parses an 128 bits bitmap.' do
			#10000000000000000001000000100000010000001000000100000010000001000000100000010000001000000100000010000001000000100000010000001000
			# generated by: 20.step(128,7) {|i| mp.set(i)}

			b = ISO8583::Bitmap.new "\x80\x00\x10\x20\x40\x81\x02\x04\x08\x10\x20\x40\x81\x02\x04\x08"

			20.step(128,7) do|i|
				expect(b[i]).to     eq(true)
				expect(!!b[i+i]).to eq(false)
			end
		end

		it 'parses the rest of a 64 bit bitmap.' do
			b, rest = ISO8583::Bitmap.parse "\x00\x49\x24\x92\x49\x24\x92\x40\x31\x32\x33\x34"

			10.step(60,3) {|i| 
				expect(b[i]).to   eq(true)
				expect(b[i+i]).to eq(false)
			}

			expect(rest).to eq("1234")
		end
	end

	context 'defines' do
		it '#each' do
			bmp = ISO8583::Bitmap.new

			bmp.set(2)
			bmp.set(3)
			bmp.set(5)
			bmp.set(6)

			ary = []

			bmp.each {|bit| ary << bit }

			expect(ary).to eq([2,3,5,6])
		end
	end
end

