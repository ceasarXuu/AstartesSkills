import { renewSubscription } from "./subscription";

test("renews an active subscription", async () => {
  const result = await renewSubscription(
    {
      id: "user-1",
      cardToken: "card-ok",
      subscription: { active: true, planId: "pro" },
    },
    { id: "pro", priceCents: 2000 },
  );

  expect(result?.status).toBe("paid");
});

