import Variable from 'resource:///com/github/Aylur/ags/variable.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js'
import App from 'resource:///com/github/Aylur/ags/app.js';

export const Uptime = Variable("0h 0m", {
  poll: [1000 * 60, ['bash', '-c', "uptime -p | sed -e 's/up //;s/ hours,/h/;s/ hour,/h/;s/ minutes/m/;s/ minute/m/'"], out => out.trim()],
})

export const Brightness = Variable(false, {
  poll: [1000, ['brightnessctl', 'g'], out => Number(out)],
})

const defaultvalue = {
  "weather": [
    {
      "id": 701,
      "main": "Weather Not Availalbe",
      "description": "Connect To Internet",
      "icon": "50d"
    }
  ],
  "base": "stations",
  "main": {
    "temp": 0,
    "feels_like": "Temp Not Available",
    "temp_min": 0,
    "temp_max": 0,
    "pressure": 0,
    "humidity": 0
  },
  "visibility": 1000,
  "wind": {
    "speed": 0,
    "deg": 0
  },
  "clouds": {
    "all": 20
  },
  "name": "New Delhi",
}

const setVars = () => {
  const g = {}
  const contents = Utils.readFile(`${App.configDir}/.env`)
  const lines = contents.toString().split("\n");
  lines.forEach(line => {
    const [key, value] = line.split("=");
    if (key && value) {
      g[key] = value
    }
  });
  return g
}

export const GLOBAL = setVars()

export const WeatherData = Variable(defaultvalue)

Utils.interval(5000, () => {
  Utils.fetch(`https://api.openweathermap.org/data/2.5/weather?q=${GLOBAL['CITY']}&appid=${GLOBAL['OPENWEATHERAPIKEY']}&units=metric`)
    .then(res => res.text())
    .then(res => {
      WeatherData.setValue(JSON.parse(res))
    })
})