#!/usr/bin/ruby

$stdin.each_line do |l|
	a = []
	l.scan(/\w+/) do |w| 
		if w == "us" then w = "\"u s\"" end
		a << w 
	end

	andthen = []
	(a.length+1).times do |n|
		disj = []
		if n == 0 then next end
		(2**(a.length)).times do |x|
			if x == 0 then next end
			item = []
			a.length.times do |index|
				if ( x & (2**index) != 0 ) then item << a[index] end
			end

			if item.length == n then disj << ( "(" + item.join(" & " ) + ")" ) end
		end
		andthen << disj.join( " | " )
	end

	puts andthen.reverse.join( ", " );
end
