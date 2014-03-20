function mark_cities(cities, map) {
	_.each(cities, function(city) {
		mark_city(city, map);
	})
}

var city_markers = {};

function mark_city(data, map) {
	if (!(data.NameComponent.name in city_markers)) {
		var marker = L.marker([data.LocationComponent.lat, data.LocationComponent.lon], {id:'test'})

		var popup = L.popup().setContent(city_description(data));
		marker.bindPopup(popup)

		marker.addTo(map);
		city_markers[data.NameComponent.name] = [marker, popup];
	} else {
		city_markers[data.NameComponent.name][1].setContent(city_description(data));
	}
}

function city_description(data) {
	var text = "<b>" + data.NameComponent.name + "</b><br>";
	text += "Population: " + commaSeparateNumber(Math.round(data.PopulationComponent.population));
	return text;
}

L.Icon.Default.imagePath = '/client/img'
var map = L.map('map').setView([39.95234, -75.16191], 10);

L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
}).addTo(map);


var client = new Faye.Client('/faye')
var subscription = client.subscribe('/public', function(msg) {
	//console.log(msg);

	if (msg.type == "update_cities") {
		mark_cities(msg.data, map);
	}
});

client.publish('/public', {type: 'new_client_connection'});

function commaSeparateNumber(val){
	while (/(\d+)(\d{3})/.test(val.toString())){
		val = val.toString().replace(/(\d+)(\d{3})/, '$1'+','+'$2');
	}
	return val;
}