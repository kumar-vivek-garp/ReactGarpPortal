/**
 * Strongly-typed data-transfer objects for the optimized event-registration
 * module (GARP_EventReg_*).
 *
 * These DTOs are the contract between the LWC and GARP_EventReg_Controller for
 * the paths that are REIMPLEMENTED standalone (address verification, RSVP
 * decline, and the post-payment confirmation payload). Field names deliberately
 * mirror the legacy GARP_Common.address / GARP_BC_Shipping / GARP_BC_Events
 * shapes so the front-end JSON contract stays familiar and migration is a
 * near drop-in.
 *
 * The delegated paths (full load payload, fees, order, payment) keep the legacy
 * JSON-string contract and are handled by GARP_EventReg_Gateway — they do NOT
 * use these DTOs, by design (the risky logic is isolated in one place).
 */
public class GARP_EventReg_Dto {

    /* ===================== Shared ===================== */

    /** Mirrors GARP_Common.address so existing client payloads deserialize as-is. */
    public class Address {
        public String company;
        public String street1;
        public String street2;
        public String street3;
        public String city;
        public String province;
        public String postalCode;
        public String country;   // matches Country_Code__c.Country__c
        public String phone;
        public String district;  // OSTA
        public String town;      // OSTA
    }

    /* ===================== Address verification ===================== */

    /** Request for verifyAddress — mirrors GARP_BC_Shipping.verifyAddressInfo. */
    public class VerifyAddressRequest {
        public Boolean hasShipping;
        public Boolean billingSameAsShipping;
        public Address billingAddress;
        public Address shippingAddress;
    }

    /** Response for verifyAddress — mirrors GARP_BC_Shipping.retVerifyAddress. */
    public class VerifyAddressResult {
        public Boolean isBillingAddressValid = true;
        public String  billingAddressErrors = '';
        public Boolean isShippingAddressValid = true;
        public String  shippingAddressErrors = '';
        public Decimal shippingAmount = 0;
        public Boolean isBillingAllowed = false;
        public Boolean isShippingAllowed = false;
        public Boolean isCreditCardAllowed = false;
        public Boolean isWireAllowed = false;
        public Boolean isCheckAllowed = false;
        public Boolean postalCodeBillingRequired = false;
        public Boolean provinceBillingRequired = false;
        public Boolean postalCodeShippingRequired = false;
        public Boolean provinceShippingRequired = false;
    }

    /* ===================== Post-payment confirmation ===================== */

    /* ===================== Standalone write-path (Phase 2) ===================== */
    // Field names mirror the legacy JSON contract so garpEventRegModernFull works unchanged.

    public class PromoCode {
        public String promoCode;
        public Boolean isValid;
        public String message;
    }

    public class MembershipOptions {
        public Boolean hasSelectedMembership;
        public Boolean hasSelectedRiskNet;
        public Boolean autoRenew;
    }

    public class CustomerInfo {
        public String firstName;
        public String lastName;
        public String email;
        public String leadId;
        public String sessionId;
        public String contactId;
        public String accountId;
        public String phone;
        public String mobilePhone;
        public String mobilePhoneCode;
        public Boolean smsPromotionalUpdates;
        public String company;
        public String title;
        // Attribution — carried from verifyExistingCustomer so the order/Form_Data
        // reflect the campaign that drove the registration (legacy Order_Summary_CTA parity).
        public String track_cta;
        public String utm_campaign;
        public String utm_content;
        public String utm_medium;
        public String utm_source;
        public String utm_term;
    }

    public class PersonalInfo {
        public String businessEmail;
        public String professionalLevel;
        public String jobFunction;
        public String riskSpecialty;
        public String company;
        public String title;
    }

    public class AddressBlock {
        public Address billingAddress;
        public Address shippingAddress;
        public Boolean billingAndShippingSame;
    }

    public class PaymentInfo {
        public String paymentType;
        public Address billingAddress;
        public String existingOrderId;
        public String existingRegistrationId;
    }

    public class EventOptions {
        public String attendanceMethod;
        public Boolean willAttendRSVPActivity;
        public String dietaryRestrictionDetails;
        public String activityQuestionResponse;
        public String eventQuestionResponse;
    }

    public class ConsentInfo {
        public Boolean privacyPolicyAttestation;
        public Boolean valuableContentAttestation;
        public Boolean sponsorContentAttestation;
    }

    public class ProgramRegInfo {
        public String registrationType;
        public String eventId;
        public String eventType;          // event | chaptermeeting | webcast
        public String formName;
        public String mainMemberProductCode;
        public String mainNonMemberProductCode;
        public Boolean allowMemberPublicRegistration;
    }

    /** Superset request used by getRegistrationFees / setRegistration / payOrder. */
    public class RegRequest {
        public CustomerInfo customerInfo;
        public PersonalInfo personalInfo;
        public PaymentInfo paymentInfo;
        public MembershipOptions membershipOptions;
        public EventOptions eventOptions;
        public ConsentInfo consentInfo;
        public AddressBlock addressInfo;
        public ProgramRegInfo programRegistrationInfo;
        public List<PromoCode> promoCodes;
        public String paymentType;
        public String affiliateCode;
        public String teamRegCode;
        public Boolean isEventBundleSelected;
        public String sessionStateJSON;
    }

    public class VerifyCustomerRequest {
        public String firstName;
        public String lastName;
        public String email;
        public String formKey;
        public String cta;
        public Boolean allowMemberPublicRegistration;
        public String leadId;
        public String sessionId;
        public String utm_campaign;
        public String utm_content;
        public String utm_medium;
        public String utm_source;
        public String utm_term;
        public String track_cta;
    }

    public class VerifyCustomerResult {
        public String status;
        public String message;
        public Boolean isCustomer;
        public String leadId;
        public String accountId;
        public String contactId;
        public String sessionId;
    }

    public class FeeLine {
        public String productCode;
        public String productName;
        public String priceId;
        public String glCode;
        public String productFamily;
        public Decimal amount;
        public Integer quantity = 1;
        public Boolean isVATTax = false;
        public Boolean isNJSalesTax = false;
        public Boolean isCompWithRegistration = false;
        public Boolean isMainProduct = false;
        public Boolean needsShipping = false;
    }

    public class FeesResult {
        public String status = 'Success';
        public String message;
        public String currencyIsoCode = 'USD';
        public List<FeeLine> feeProducts = new List<FeeLine>();
        public List<FeeLine> feeProductsForDisplay = new List<FeeLine>();
        public Decimal total = 0;
        public Decimal subTotal = 0;
        public Decimal njSalesTax = 0;
        public FeeLine vatSalesTax;
        public Boolean needsShipping = false;
        public Boolean hasBilling = false;
        public Boolean hasSubtotal = false;
        public Boolean hasCompMembership = false;
        public Integer compMembershipTerm;
        public List<PromoCode> promoCodes = new List<PromoCode>();
    }

    public class RegResult {
        public String status;
        public String message;
        public String contactId;
        public String accountId;
        public String orderId;
        public String registrationId;
        public String orderNumber;
        public String company;
        public Decimal total;
        public Decimal tax;
        public Decimal shipping;
    }

    public class PaymentStatusResult {
        public Boolean isOrderFound = false;
        public Boolean isPaymentFound = false;
        public Boolean isPaymentSuccess = false;
        public Boolean isOrderRolledback = false;
        public String paymentType;
    }

    /**
     * Event detail rendered on the confirmation page (garpRegistrationSuccess).
     * Field names mirror the legacy GARP_BC_Events.eventInfo so the LWC change
     * to consume this typed shape is minimal.
     */
    public class EventCompletionInfo {
        public String  eventId;
        public String  eventType;           // event | chaptermeeting | webcast
        public String  title;
        public String  description;
        public String  chapterName;
        public String  deliveryMode;
        public String  deliveryModeDescription;
        public Datetime startDateTime;
        public Datetime endDateTime;
        public String  timeZone;
        public String  locationDescription;
        public Boolean isOnDemand = false;
        public String  onlineMeetingURL;
        public String  on24Url;
        public String  on24Id;
        public String  on24ApiKey;
        public String  sponsorName;
        public String  sponsorPolicyURL;
        public Boolean isSponsored = false;
        public Boolean isInviteOnly = false;
        public String  formKey;
        public Boolean found = false;       // false => event not found / inactive
    }
}