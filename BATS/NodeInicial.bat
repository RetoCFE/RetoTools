@echo off
SET /P nombre_proyecto= Introduce el nombre del proyecto: 
SET /P descripcion_proyecto= Introduce la descripcion del proyecto: 
mkdir %nombre_proyecto%
cd %nombre_proyecto%
echo { > package.json
echo     "name": "%nombre_proyecto%", >> package.json
echo     "version": "1.0.0", >> package.json
echo     "description": "%descripcion_proyecto%", >> package.json
echo     "main": "%nombre_proyecto%.js", >> package.json
echo     "scripts": { >> package.json
echo         "dev": "pm2 start %nombre_proyecto%.js --max-memory-restart 300M --exp-backoff-restart-delay=100" >> package.json
echo     }, >> package.json
echo     "author": "Luis Alejandro Canchola Pedraza", >> package.json
echo     "license": "ISC", >> package.json
echo     "dependencies": { >> package.json
echo         "dotenv": "^16.0.0", >> package.json
echo         "express": "^4.17.2", >> package.json
echo         "express-validator": "^6.14.0", >> package.json
echo         "pm2": "^5.2.0", >> package.json
echo         "request": "^2.88.2", >> package.json
echo         "sequelize": "^6.20.1", >> package.json
echo         "tedious": "^14.7.0" >> package.json
echo     } >> package.json
echo } >> package.json

echo require('dotenv').config(); > %nombre_proyecto%.js
echo const Server = require("./models/Server"); >> %nombre_proyecto%.js
echo. >> %nombre_proyecto%.js
echo const server = new Server(); >> %nombre_proyecto%.js
echo server.listen(); >> %nombre_proyecto%.js

echo. >> .env
echo PORT=9000 >> .env
echo DB_NAME= >>.env
echo DB_USER= >>.env
echo DB_PASS=  >>.env
echo DB_HOST1= >> .env
mkdir config
mkdir controllers
mkdir external
mkdir middlewares
mkdir models
mkdir routes
@REM Se crea el archivo validate_data
echo const { validationResult } = require('express-validator'); > middlewares\validate_camps.js
echo. >> middlewares\validate_camps.js
echo const validateCamps = (req, res, next) =^>^ { >> middlewares\validate_camps.js
echo     // Obtener arrays de errores >> middlewares\validate_camps.js
echo     const errors = validationResult(req); >> middlewares\validate_camps.js
echo     // Validar si el array tiene algo. >> middlewares\validate_camps.js
echo     let bad={} >> middlewares\validate_camps.js
echo     bad['Date:']=new Date(); >> middlewares\validate_camps.js
echo     bad['IP:']=req.ip; >> middlewares\validate_camps.js
echo     bad['Method:']=req.method; >> middlewares\validate_camps.js
echo     bad['URL:']=req.url; >> middlewares\validate_camps.js
echo     bad['Body:']=req.body; >> middlewares\validate_camps.js
echo     bad['Error']=JSON.stringify(errors); >> middlewares\validate_camps.js
echo     console.log(JSON.stringify(bad)); >> middlewares\validate_camps.js
echo     if (!errors.isEmpty()) return res.status(400).json({ >> middlewares\validate_camps.js
echo         code: 400, >> middlewares\validate_camps.js
echo         resultado: "Hubo un error con los parametros", >> middlewares\validate_camps.js
echo         errors: errors.mapped() >> middlewares\validate_camps.js
echo     }); >> middlewares\validate_camps.js
echo     // Si no hay errores llama al controller.  >> middlewares\validate_camps.js
echo     next(); >> middlewares\validate_camps.js
echo } >> middlewares\validate_camps.js
echo. >> middlewares\validate_camps.js
echo //**...  EXPORTACION DE MIDDLEWARES   ....**// >> middlewares\validate_camps.js
echo module.exports = { >> middlewares\validate_camps.js
echo     validateCamps, >> middlewares\validate_camps.js
echo } >> middlewares\validate_camps.js
echo //Author:Luis Alejandro Canchola Pedraza >> middlewares\validate_camps.js
@REM Se crea el archivo v

echo const Sequelize = require("sequelize"); > config\db.js
echo. >> config\db.js
echo const Host1 = new Sequelize(process.env.DB_NAME, process.env.DB_USER, process.env.DB_PASS, { >> config\db.js
echo     host: process.env.DB_HOST1, >> config\db.js
echo     ...sequelizeOptions >> config\db.js
echo }); >> config\db.js
echo. >> config\db.js
echo const sequelizeOptions = { >> config\db.js
echo     dialect: 'mssql', >> config\db.js
echo     pool: { >> config\db.js
echo         max: 5, >> config\db.js
echo         min: 0, >> config\db.js
echo         acquire: 30000, >> config\db.js
echo         idle: 10000 >> config\db.js
echo     }, >> config\db.js
echo     cryptoCredentialsDetails : { >> config\db.js
echo         minVersion:'TLSv1' >> config\db.js
echo     }, >> config\db.js
echo     options: { >> config\db.js
echo         encrypt: false, >> config\db.js
echo         enableArithAbort: false, >> config\db.js
echo         cryptoCredentialsDetails: { >> config\db.js
echo             minVersion: 'TLSv1' >> config\db.js
echo         }, >> config\db.js
echo     }, >> config\db.js
echo     dialectOptions: { >> config\db.js
echo         encrypt: true, >> config\db.js
echo         useUTC: false, // for reading from database >> config\db.js
echo         cryptoCredentialsDetails: { >> config\db.js
echo             minVersion: 'TLSv1' >> config\db.js
echo         }, >> config\db.js
echo         options: { >> config\db.js
echo             requestTimeout : 30000000, >> config\db.js
echo             enableArithAbort: false, >> config\db.js
echo             encrypt: false, >> config\db.js
echo             trustServerCertificate: true, >> config\db.js
echo             cryptoCredentialsDetails: { >> config\db.js
echo                 minVersion: 'TLSv1' >> config\db.js
echo             } >> config\db.js
echo         } >> config\db.js
echo     }, >> config\db.js
echo     timezone: "America/Mexico_city" >> config\db.js
echo }; >> config\db.js
echo. >> config\db.js
echo module.exports = {Host1};>> config\db.js
echo //Author:Luis Alejandro Canchola Pedraza>> config\db.js
@REM Agregando Controladores
echo const { response, request } = require('express'); > controllers\firstcontroller.js
echo. >> controllers\firstcontroller.js
echo const [NombreFuncion] = async (req = request, res = response) =^> ^{ >> controllers\firstcontroller.js
echo     let options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric', hour: 'numeric', minute: 'numeric', second: 'numeric' }; >> controllers\firstcontroller.js
echo     let date = new Date(); >> controllers\firstcontroller.js
echo     let fecha = date.toLocaleDateString("es-ES", options); >> controllers\firstcontroller.js
echo     let resultado; >> controllers\firstcontroller.js
echo     let code; >> controllers\firstcontroller.js
echo     const success = {}; >> controllers\firstcontroller.js
echo     try { >> controllers\firstcontroller.js
echo         console.log(`*********INICIA CONSULTA DE [NombreFuncion]*********`); >> controllers\firstcontroller.js
echo         console.log(`*****************${fecha}*******************`); >> controllers\firstcontroller.js
echo         //Inicia Insert de datos >> controllers\firstcontroller.js
echo         resultado = 'Exito'; >> controllers\firstcontroller.js
echo         code = 200; >> controllers\firstcontroller.js
echo         success['Date'] = fecha; >> controllers\firstcontroller.js
echo         success['Code'] = code; >> controllers\firstcontroller.js
echo         success['Result'] = resultado; >> controllers\firstcontroller.js
echo         //Response >> controllers\firstcontroller.js
echo         success['Data'] = Data; >> controllers\firstcontroller.js
echo         console.log(success); >> controllers\firstcontroller.js
echo         console.log(`*********TERMINA BUSQUEDA DE [NombreFuncion]*********`); >> controllers\firstcontroller.js
echo     } catch (error) { >> controllers\firstcontroller.js
echo         resultado = 'Fallo'; >> controllers\firstcontroller.js
echo         code = 500; >> controllers\firstcontroller.js
echo         success['Date:'] = fecha; >> controllers\firstcontroller.js
echo         success['Result:'] = resultado; >> controllers\firstcontroller.js
echo         success['Code:'] = code; >> controllers\firstcontroller.js
echo         success['Error:'] = error.message; >> controllers\firstcontroller.js
echo         console.log('************************FINALIZA CONSULTA DE [NombreFuncion]************************'); >> controllers\firstcontroller.js
echo         console.log('**************************************************************************'); >> controllers\firstcontroller.js
echo     } >> controllers\firstcontroller.js
echo     return success; >> controllers\firstcontroller.js
echo } >> controllers\firstcontroller.js
echo. >> controllers\firstcontroller.js
echo module.exports = { >> controllers\firstcontroller.js
echo     [NombreFuncion] >> controllers\firstcontroller.js
echo } >> controllers\firstcontroller.js
echo //Author:Luis Alejandro Canchola Pedraza >> controllers\firstcontroller.js
@REM Agregando Server
echo const express = require('express'); > models\Server.js
echo const cors = require('cors'); >> models\Server.js
echo const express = require('express'); > models\Server.js
echo const cors = require('cors'); >> models\Server.js
echo //Agregando configuraciones DB >> models\Server.js
echo const {Host1} = require('../config/db'); >> models\Server.js
echo. >> models\Server.js
echo //Author:Luis Alejandro Canchola Pedraza >> models\Server.js
echo. >> models\Server.js
echo class Server { >> models\Server.js
echo. >> models\Server.js
echo     constructor() { >> models\Server.js
echo. >> models\Server.js
echo         this.app = express(); >> models\Server.js
echo         this.path = { >> models\Server.js
echo             //Se declara la carpeta inicial  >> models\Server.js
echo             %nombre_proyecto%: '/api/v1/%nombre_proyecto%/', >> models\Server.js
echo         } >> models\Server.js
echo         this.configDB(); >> models\Server.js
echo         this.midlewares(); >> models\Server.js
echo         this.routes(); >> models\Server.js
echo     } >> models\Server.js
echo. >> models\Server.js
echo     routes() { >> models\Server.js
echo         //Se trae el archivo de rutas >> models\Server.js
echo         this.app.use(this.path.%nombre_proyecto%, require('../routes/%nombre_proyecto%')); >> models\Server.js
echo     } >> models\Server.js
echo. >> models\Server.js
echo     configDB() { >> models\Server.js
echo         this.connectionDDBB(); >> models\Server.js
echo     } >> models\Server.js
echo. >> models\Server.js
echo     async connectionDDBB() { >> models\Server.js
echo. >> models\Server.js
echo         try { >> models\Server.js
echo             //Se realizan las validaciones de conexion a base >> models\Server.js
echo             await Host1.authenticate(); >> models\Server.js
echo             console.log('Connection has been established successfully.'); >> models\Server.js
echo. >> models\Server.js
echo         } catch (error) { >> models\Server.js
echo. >> models\Server.js
echo             console.error('Unable to connect to the database:', error); >> models\Server.js
echo         } >> models\Server.js
echo. >> models\Server.js
echo     } >> models\Server.js
echo. >> models\Server.js
echo     midlewares() { >> models\Server.js
echo. >> models\Server.js
echo         this.app.use(cors()); >> models\Server.js
echo         this.app.use(express.json()); >> models\Server.js
echo         this.app.use(express.static('public')); >> models\Server.js
echo         this.app.use(express.urlencoded({ extended: true })); >> models\Server.js
echo     } >> models\Server.js
echo. >> models\Server.js
echo     listen() {>> models\Server.js
echo 		this.app.set('port', process.env.PORT ^|^| 9009); >>models\Server.js

echo     	this.app.listen(this.app.get('port'), () =^>^{  >> models\Server.js
echo             console.log(`Aplicacion corriendo en el port ${this.app.get('port')}`) >> models\Server.js
echo         }); >> models\Server.js
echo     } >> models\Server.js
echo. >> models\Server.js
echo } >> models\Server.js
echo. >> models\Server.js
echo module.exports = Server; >> models\Server.js
@REM Agregando rutas

echo const { Router } = require('express'); > routes\%nombre_proyecto%.js
echo const { check } = require('express-validator'); >> routes\%nombre_proyecto%.js
echo const { validateCamps } = require('../middlewares/validate_camps'); >> routes\%nombre_proyecto%.js
echo //Importar controladores >> routes\%nombre_proyecto%.js
echo. >> routes\%nombre_proyecto%.js
echo //Author:Luis Alejandro Canchola Pedraza >> routes\%nombre_proyecto%.js
echo const router = Router(); >> routes\%nombre_proyecto%.js
echo //Se ingresan las ruta >> routes\%nombre_proyecto%.js
echo router.get('/ejemplo', >> routes\%nombre_proyecto%.js
echo     //Ingresar controllador >> routes\%nombre_proyecto%.js
echo   %nombre_proyecto%DB >> routes\%nombre_proyecto%.js
echo ); >> routes\%nombre_proyecto%.js
@REM Testo con check
echo. >> routes\%nombre_proyecto%.js
echo router.get('/Micar', [ >> routes\%nombre_proyecto%.js
echo    check('FechaInicial') >> routes\%nombre_proyecto%.js
echo      .notEmpty().withMessage('Fecha inicial es obligatoria') >> routes\%nombre_proyecto%.js
echo      .matches(/^\d{2}\/\d{2}\/\d{4} \d{2}:\d{2}:\d{2}$/) >> routes\%nombre_proyecto%.js
echo      .withMessage('Fecha inicial debe tener el formato adecuado (MM/DD/YYYY HH:mm:ss)'),   >> routes\%nombre_proyecto%.js
echo    check('FechaFinal') >> routes\%nombre_proyecto%.js
echo      .notEmpty().withMessage('Fecha final es obligatoria') >> routes\%nombre_proyecto%.js
echo      .matches(/^\d{2}\/\d{2}\/\d{4} \d{2}:\d{2}:\d{2}$/) >> routes\%nombre_proyecto%.js
echo      .withMessage('Fecha final debe tener el formato adecuado (MM/DD/YYYY HH:mm:ss)'),  >> routes\%nombre_proyecto%.js
echo    validateCamps >> routes\%nombre_proyecto%.js
echo  ], Micar); >> routes\%nombre_proyecto%.js
echo. >> routes\%nombre_proyecto%.js
echo module.exports = router; >> routes\%nombre_proyecto%.js
npm install
cmd /K
pause


