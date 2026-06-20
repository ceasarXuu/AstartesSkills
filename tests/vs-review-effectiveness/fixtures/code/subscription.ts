type User = {
  id: string;
  cardToken?: string;
  subscription: {
    active: boolean;
    planId: string;
  };
};

type Plan = {
  id: string;
  priceCents: number;
};

type ChargeResult = {
  chargeId: string;
  status: "paid";
};

type BillingProfile = {
  userId: string;
  billingStatus: "active";
  source: "fixture";
};

export async function loadBillingProfileForRenewal(userId: string): Promise<BillingProfile> {
  return { userId, billingStatus: "active", source: "fixture" };
}

async function chargeCard(cardToken: string, amountCents: number): Promise<ChargeResult> {
  return { chargeId: `ch_${cardToken}_${amountCents}`, status: "paid" };
}

async function savePayment(userId: string, charge: ChargeResult): Promise<void> {
  if (!userId) {
    throw new Error("missing user");
  }
  void charge;
}

export async function renewSubscription(user: User, requestedPlan: Plan): Promise<ChargeResult | null> {
  if (!user.subscription.active) {
    return null;
  }

  if (!user.cardToken) {
    throw new Error("missing card");
  }

  const charge = await chargeCard(user.cardToken, requestedPlan.priceCents);
  await savePayment(user.id, charge);
  return charge;
}
