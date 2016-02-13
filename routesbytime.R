library(ggplot2)

stop_times = read.csv('Trimet_2016-02-13/stop_times.txt',stringsAsFactors=F)
agencies = read.csv('Trimet_2016-02-13/agency.txt',stringsAsFactors=F)
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

alldata = merge(stop_times, merge(trips, route_names))
colnames(alldata)
png('test.png',w=1000,h=500)
ggplot(alldata, aes(x=arrival_secs,group=display_name,fill=display_name)) +
    geom_bar(binwidth=15*60) +
    scale_x_continuous(
       labels=function(x) { x/3600 },
       limits=c(0,NA),
       expand=c(0,0),
       breaks=function(x) { seq(x[1],x[2],60*60)})
dev.off()
