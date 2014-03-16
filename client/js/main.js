var client = new Faye.Client('/faye')
var subscription = client.subscribe('/public', function(msg) {
	console.log(msg);
});

client.publish('/public', {text: 'new_client'});

var map = L.map('map').setView([51.505, -0.09], 18);

L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
}).addTo(map);
