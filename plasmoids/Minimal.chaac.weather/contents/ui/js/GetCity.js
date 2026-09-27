function getNameCity(latitude, longitud, leng, callback) {
    function fetchCity(useLanguage) {
        let url = `https://nominatim.openstreetmap.org/reverse?format=json&lat=${latitude}&lon=${longitud}`;
        if (useLanguage) {
            url += `&accept-language=${leng}`;
        }

        console.log("Generated URL: ", url);

        let req = new XMLHttpRequest();
        req.open("GET", url, true);

        req.onreadystatechange = function () {
            if (req.readyState === 4) {
                if (req.status === 200) {
                    try {
                        let datos = JSON.parse(req.responseText);
                        let address = datos.address || {};
                        let city = address.city;
                        let county = address.county;
                        let state = address.state;
                        let full = city ? city : state ? state : county;

                        console.log("Parsed location:", full);

                        if (full === "Language not supported" && useLanguage) {
                            console.log("Retrying without language parameter...");
                            fetchCity(false); // llamada sin accept-language
                        } else {
                            callback(full);
                        }
                    } catch (e) {
                        console.error("Error al analizar la respuesta JSON: ", e);
                    }
                } else {
                    console.error("city failed, status: " + req.status);
                }
            }
        };

        req.onerror = function () {
            console.error("La solicitud falló");
        };

        req.ontimeout = function () {
            console.error("La solicitud excedió el tiempo de espera");
        };

        req.send();
    }

    // primera llamada con parámetro de idioma
    fetchCity(true);
}


