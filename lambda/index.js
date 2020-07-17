require("dotenv").config();
const client = require("twilio")(
	process.env.TWILIO_SID,
	process.env.TWILIO_TOKEN
);

exports.handler = async function(event, context) {
	try {
		const message = await client.messages.create({
			body: "New log file uploaded!",
			from: process.env.FROM_NUMBER,
			to: process.env.TO_NUMBER,
		});
		return {
			statusCode: 200,
		};
	} catch (error) {
		return {
			statusCode: 500,
			body: error.message,
		};
	}
};
