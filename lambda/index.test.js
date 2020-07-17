const createEvent = require("aws-event-mocks");
const { handler } = require("./index.js");

test("handles s3 notification", async () => {
	const event = createEvent({
		template: "aws:s3",
		merge: {
			Records: [
				{
					eventName: "ObjectCreated:Put",
					s3: {
						bucket: {
							name: "s3-log-bucket.operata.com",
						},
						object: {
							key: "test.log",
						},
					},
				},
			],
		},
	});
	const res = await handler(event, {});
	expect(res.statusCode).toBe(200);
});
