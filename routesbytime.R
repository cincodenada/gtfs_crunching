library(ggplot2)

show_date="20160212"

test_limit=F
#test_limit=100000 # Uncomment to load less stuff for speed while testing
#stop_times = read.csv('Trimet_2016-02-13/stop_times_sample.txt',stringsAsFactors=F)
stop_times = read.csv('Trimet_2016-02-13/stop_times.txt',nrow=test_limit,stringsAsFactors=F)
agencies = read.csv('Trimet_2016-02-13/agency.txt',stringsAsFactors=F)
calendar_dates = read.csv('Trimet_2016-02-13/calendar_dates.txt',stringsAsFactors=F)
routes = read.csv('Trimet_2016-02-13/routes.txt',stringsAsFactors=F)
trips = read.csv('Trimet_2016-02-13/trips.txt',stringsAsFactors=F)
time_to_secs = function(x) {
    parts = unlist(strsplit(x, ':'))
    val = as.numeric(parts[1])*60*60+as.numeric(parts[2])*60+as.numeric(parts[3])
}
stop_times$arrival_secs = sapply(stop_times$arrival_time, time_to_secs)
stop_times$departure_secs = sapply(stop_times$departure_time, time_to_secs)

#start_end = aggregate(.~trip_id, subset(stop_times, select=c(trip_id,arrival_secs,departure_secs)), function(x) c(minval = min(x), maxval = max(x)))
#alldata = merge(start_end, merge(routes,trips))
# Copy id -> name generally
route_names = merge(routes, agencies)
route_names$display_name = route_names$agency_name
# Special cases
# Separate MAX and Bus
route_names$display_name[route_names$agency_id=="TRIMET"] = "TriMet Bus"
route_names$display_name[grepl("MAX",route_names$route_long_name)] = "TriMet MAX"
route_names$display_name[grepl("WES",route_names$route_long_name)] = "WES Commuter Rail"

trip_dates = merge(trips, calendar_dates)
trip_dates = trip_dates[trip_dates$date==show_date,]
alldata = merge(stop_times, merge(trip_dates, route_names))

num_instances = as.data.frame(table(alldata$display_name))
colnames(num_instances) = c('display_name','num_instances')
alldata = merge(alldata, num_instances)

colnames(alldata)
p = ggplot(alldata, aes(x=arrival_secs,group=display_name,fill=display_name)) +
    geom_bar(binwidth=15*60, aes(order=num_instances)) +
    scale_x_continuous(
       labels=function(x) { hr=x/3600; res=paste((hr-1)%%12+1, ifelse(hr%%24<12, "am", "pm"),sep="") },
       limits=c(0,NA),
       expand=c(0,0),
       breaks=function(x) { seq(x[1],x[2],60*60)}
    ) +
    labs(title="Transit Stop Arrivals in Portland, OR",x="Time",y="Number of arrivals")
png('PortlandTransit.png',w=5000,h=2000,res=300)
    p
dev.off()
png('PortlandTransitMultiples.png',w=5000,h=2000,res=300)
    p + facet_wrap(~display_name,ncol=3)
dev.off()
