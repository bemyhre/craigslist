require 'open-uri'
require 'nokogiri'
filename = "printing.html"
script = $0

def get_post_date(listing_url) #this method takes in a page and returns a date - by far the most intensive process
	listing=Nokogiri::HTML(open(listing_url)).css("p")
	setter=""
	for element in listing
      if element.css('time').text!=""&&setter==""
      	post_time =Time.parse(element.css('time').text)
  	    return post_time
      end
    end
end

def main_page(location,term) #this takes in a search url and return a hash of links page names and postdates for that locaton
  job_master={}
  location.each do |p|
    open_search_page=Nokogiri::HTML(open("http://#{p}.craigslist.org/search/jjj?query=#{term}&zoomToPosting=")).css("a")
    for x in open_search_page
      if (x.attr("href")[0]=="/")&&(x.attr("href")[-1]=="l")&&(x.attr("class")!="i")
          job_master["http://#{p}.craigslist.com#{x.attr("href")}"]={"time"=>get_post_date("http://#{p}.craigslist.com#{x.attr("href")}"), "text"=>x.text, "location"=>p}
      end
    end
  end
  return job_master
end

def print_page(location,time,term)
  main_page(location,term).sort_by{|k,v| v["time"]}.reverse.each do |x|
    if x[1]["time"]>time
      Target.write("Time Posted: #{x[1]["time"]}  <a href='#{x[0]}' target='_blank'>#{x[1]['location']} - #{x[1]["text"]}</a><br/>")
    end
  end
end

def get_data()
  loc_entry=[]
  print "Enter one search word (or enter for default):"
  term=gets.chomp()
  if term==nil
    term="ruby"
  end
  keeper=1
  until keeper=="" do
    p "What is a location(craigslist prefix)"
    print ">"
    keeper=gets.chomp()
    loc_entry.push(keeper)
  end
  if loc_entry.length>1
    return loc_entry[0..-2],term
  else
    return ["sfbay","sandiego", "orangecounty", "losangeles", "portland","seattle"],term
  end
end
location,term=get_data

Target=File.open(filename,'w')
t=Time.now-200000
Target.write("<html><title>Recent Multiple Location search results</title><body>")
print_page(location,t,term)
Target.write("</body></html>")





