// Make Faye connection
var client = new Faye.Client('/faye')
var subscription = client.subscribe('/public', function(msg) {
	//console.log(msg);

	if (msg.type == "update_cities") {
		mark_cities(msg.data, map);
	} else if (msg.type == "update_forces") {
		mark_forces(msg.data, map);
	}
});

client.publish('/public', {type: 'new_client_connection'});

// Setup map
L.Icon.Default.imagePath = '/client/img'
var map = L.map('map').setView([39.95234, -75.16191], 10);

L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
}).addTo(map);

// Add cities to map
var city_markers = {};

function mark_cities(cities, map) {
	_.each(cities, function(city) {
		mark_city(city, map);
	})
}

function mark_city(data, map) {
	if (!(data.UuidComponent.uuid in city_markers)) {
		var marker = L.marker([data.LocationComponent.lat, data.LocationComponent.lon]);

		var popup = L.popup().setContent(city_description(data));
		marker.bindPopup(popup)

		marker.addTo(map);
		city_markers[data.UuidComponent.uuid] = [marker, popup];
	} else {
		city_markers[data.UuidComponent.uuid][1].setContent(city_description(data));
	}
}

function city_description(data) {
	var text = "<b>" + data.NameComponent.name + "</b><br>";
	text += "Population: " + commaSeparateNumber(Math.round(data.PopulationComponent.population));
	return text;
}

function commaSeparateNumber(val){
	while (/(\d+)(\d{3})/.test(val.toString())){
		val = val.toString().replace(/(\d+)(\d{3})/, '$1'+','+'$2');
	}
	return val;
}

// Add forces to map
var force_markers = {}

var marker_force_icon = L.icon({
	iconUrl: '/client/img/marker-icon-force.png',
	shadowUrl: '/client/img/marker-shadow.png',
	iconSize: [25, 41],
	iconAnchor: [12, 41],
	popupAnchor: [1, -34],
	shadowSize: [41, 41]
});

function mark_forces(cities, map) {
	_.each(cities, function(city) {
		mark_force(city, map);
	})
}

function mark_force(data, map) {
	if (!(data.UuidComponent.uuid in force_markers)) {
		var marker = L.marker(
			[data.LocationComponent.lat, data.LocationComponent.lon],
			{icon: marker_force_icon}
			);


		var popup = L.popup().setContent("Force");
		marker.bindPopup(popup)

		marker.addTo(map);
		force_markers[data.UuidComponent.uuid] = [marker, popup];
	} else {
		force_markers[data.UuidComponent.uuid][1].setContent("Force");
	}
}