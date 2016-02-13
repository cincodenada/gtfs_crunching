library(ggplot2)

stop_times = read.csv('Trimet_2016-02-13/stop_times.txt',stringsAsFactors=F)
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
alldata = merge(stop_times, merge(routes,trips))
colnames(alldata)
png('test.png',w=1000,h=500)
ggplot(alldata, aes(x=arrival_secs,group=agency_id,fill=agency_id)) + geom_bar()
dev.off()
