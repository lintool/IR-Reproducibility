#!/usr/bin/ruby

$stdin.each_line do |l|
	a = []
	l.scan(/\w+/) do |w| 
		if w == "US" then w = "\"u s\"" end
		a << w 
	end

	andthen = []
	(a.length+1).times do |n|
		window = []
		conj = []
		if n == 0 then next end
		(2**(a.length)).times do |x|
			if x == 0 then next end
			item = []
			a.length.times do |index|
				if ( x & (2**index) != 0 ) then item << a[index] end
			end

			if item.length == n then 
				if n > 1; then
					window << ( "(" + item.join(" & " ) + ")~" + (2*n).to_s )
				end
				conj<< ( "(" + item.join(" & " ) + ")" )
			end
		end
		andthen << conj.join( " | " )
		if n > 1; then 
			andthen << window.join( " | " )
		end
	end

	puts andthen.reverse.join( ", " );
end
