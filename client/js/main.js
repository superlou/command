function mark_cities(cities, map) {
	_.each(cities, function(city) {
		mark_city(city, map);
	})
}

function mark_city(data, map) {
	L.marker([data.LocationComponent.lat, data.LocationComponent.lon]).addTo(map);
}

L.Icon.Default.imagePath = '/client/img'
var map = L.map('map').setView([39.95234, -75.16191], 10);

L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
}).addTo(map);


var client = new Faye.Client('/faye')
var subscription = client.subscribe('/public', function(msg) {
	console.log(msg);

	if (msg.type == "update_cities") {
		mark_cities(msg.data, map);
	}
});

client.publish('/public', {type: 'new_client_connection'});