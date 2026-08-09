export type Maybe<T> = T | null;
export type InputMaybe<T> = Maybe<T>;
export type Exact<T extends { [key: string]: unknown }> = { [K in keyof T]: T[K] };
export type MakeOptional<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]?: Maybe<T[SubKey]> };
export type MakeMaybe<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]: Maybe<T[SubKey]> };
export type MakeEmpty<T extends { [key: string]: unknown }, K extends keyof T> = { [_ in K]?: never };
export type Incremental<T> = T | { [P in keyof T]?: P extends ' $fragmentName' | '__typename' ? T[P] : never };
/** All built-in and custom scalars, mapped to their actual values */
export type Scalars = {
  ID: { input: string; output: string; }
  String: { input: string; output: string; }
  Boolean: { input: boolean; output: boolean; }
  Int: { input: number; output: number; }
  Float: { input: number; output: number; }
  Base64: { input: string; output: string; }
  Currency: { input: number | string; output: number; }
  Date: { input: string; output: string; }
  DateTime: { input: string; output: string; }
  Double: { input: number | string; output: number; }
  Email: { input: string; output: string; }
  EncryptedString: { input: string; output: string; }
  /** Can be set to an ID or a Reference to the result of another mutation operation. */
  IdOrRef: { input: string; output: string; }
  JSON: { input: string; output: string; }
  Latitude: { input: number | string; output: number; }
  /** A 64-bit signed integer */
  Long: { input: number; output: number; }
  LongTextArea: { input: string; output: string; }
  Longitude: { input: number | string; output: number; }
  MultiPicklist: { input: string; output: string; }
  Percent: { input: number | string; output: number; }
  PhoneNumber: { input: string; output: string; }
  Picklist: { input: string; output: string; }
  RichTextArea: { input: string; output: string; }
  TextArea: { input: string; output: string; }
  Time: { input: string; output: string; }
  Url: { input: string; output: string; }
};

export enum DataType {
  Address = 'ADDRESS',
  Anytype = 'ANYTYPE',
  Base64 = 'BASE64',
  Boolean = 'BOOLEAN',
  Combobox = 'COMBOBOX',
  Complexvalue = 'COMPLEXVALUE',
  Currency = 'CURRENCY',
  Date = 'DATE',
  Datetime = 'DATETIME',
  Double = 'DOUBLE',
  Email = 'EMAIL',
  Encryptedstring = 'ENCRYPTEDSTRING',
  Int = 'INT',
  Json = 'JSON',
  Junctionidlist = 'JUNCTIONIDLIST',
  Location = 'LOCATION',
  Long = 'LONG',
  Multipicklist = 'MULTIPICKLIST',
  Percent = 'PERCENT',
  Phone = 'PHONE',
  Picklist = 'PICKLIST',
  Reference = 'REFERENCE',
  String = 'STRING',
  Textarea = 'TEXTAREA',
  Time = 'TIME',
  Url = 'URL'
}

export enum FieldExtraTypeInfo {
  ExternalLookup = 'EXTERNAL_LOOKUP',
  ImageUrl = 'IMAGE_URL',
  IndirectLookup = 'INDIRECT_LOOKUP',
  Personname = 'PERSONNAME',
  Plaintextarea = 'PLAINTEXTAREA',
  Richtextarea = 'RICHTEXTAREA',
  SwitchablePersonname = 'SWITCHABLE_PERSONNAME'
}

export enum LayoutComponentType {
  Canvas = 'CANVAS',
  CustomLink = 'CUSTOM_LINK',
  EmptySpace = 'EMPTY_SPACE',
  Field = 'FIELD',
  ReportChart = 'REPORT_CHART',
  VisualforcePage = 'VISUALFORCE_PAGE'
}

export enum LayoutMode {
  Create = 'CREATE',
  Edit = 'EDIT',
  View = 'VIEW'
}

export enum LayoutType {
  Compact = 'COMPACT',
  Full = 'FULL'
}

export enum ResultOrder {
  Asc = 'ASC',
  Desc = 'DESC'
}

export enum TabOrder {
  LeftRight = 'LEFT_RIGHT',
  TopDown = 'TOP_DOWN'
}

export enum UiBehavior {
  Edit = 'EDIT',
  Readonly = 'READONLY',
  Required = 'REQUIRED'
}

export type AccountContactQueryVariables = Exact<{
  contactId: Scalars['ID']['input'];
  first: Scalars['Int']['input'];
}>;


export type AccountContactQuery = { uiapi: { query: { Contact?: { edges?: Array<{ node?: { Id: string, FirstName?: { value?: string | null } | null, LastName?: { value?: string | null } | null, Name?: { value?: string | null } | null, Email?: { value?: string | null } | null, Phone?: { value?: string | null } | null, Photo_URL__c?: { value?: string | null } | null, GARP_Member_ID__c?: { value?: string | null } | null, GARP_ID__c?: { value?: string | null } | null, Membership_Type__c?: { value?: string | null } | null, MPS_Membership_Status__c?: { value?: string | null } | null, KPI_Membership_Expiration_Date__c?: { value?: string | null } | null, Membership_Caluclated_Expiration_Date__c?: { value?: string | null } | null, MPS_Membership_Expire_Date__c?: { value?: string | null } | null, KPI_Membership_Since__c?: { value?: string | null } | null, MPS_Membership_Autorenew_On__c?: { value?: boolean | null } | null, Company__c?: { value?: string | null } | null, Corporate_Title__c?: { value?: string | null } | null, Job_Function__c?: { value?: string | null } | null, Company_City__c?: { value?: string | null } | null, Company_Country__c?: { value?: string | null } | null, Industry_Working_Year__c?: { value?: string | null } | null, Highest_Degree__c?: { value?: string | null } | null, School_Name__c?: { value?: string | null } | null, Degree_Program_Name__c?: { value?: string | null } | null, Currently_in_School__c?: { value?: boolean | null } | null, Risk_Specialty__c?: { value?: string | null } | null, Topics_or_Expertise__c?: { value?: string | null } | null, GARP_Directory_Opt_In__c?: { value?: boolean | null } | null, GARP_Directory_Connect_Feature__c?: { value?: boolean | null } | null, GARP_Dir_Privacy_Job_Information__c?: { value?: boolean | null } | null, GARP_Dir_Privacy_Prof_Background__c?: { value?: boolean | null } | null, GARP_Dir_Privacy_Additional_Detail__c?: { value?: boolean | null } | null, KPI_Primary_Chapter_Name__c?: { value?: string | null } | null, KPI_Secondary_Chapter_Name__c?: { value?: string | null } | null, MailingStreet?: { value?: string | null } | null, MailingCity?: { value?: string | null } | null, MailingState?: { value?: string | null } | null, MailingPostalCode?: { value?: string | null } | null, MailingCountry?: { value?: string | null } | null, OtherStreet?: { value?: string | null } | null, OtherCity?: { value?: string | null } | null, OtherState?: { value?: string | null } | null, OtherPostalCode?: { value?: string | null } | null, OtherCountry?: { value?: string | null } | null, Account?: { Id: string, BillingStreet?: { value?: string | null } | null, BillingCity?: { value?: string | null } | null, BillingState?: { value?: string | null } | null, BillingPostalCode?: { value?: string | null } | null, BillingCountry?: { value?: string | null } | null } | null } | null } | null> | null, pageInfo: { hasNextPage: boolean, endCursor?: string | null } } | null } } };

export type ContactProfileExtrasQueryVariables = Exact<{
  contactId: Scalars['ID']['input'];
  first: Scalars['Int']['input'];
}>;


export type ContactProfileExtrasQuery = { uiapi: { query: { Contact?: { edges?: Array<{ node?: { Id: string, Name?: { value?: string | null } | null, GARP_Member_ID__c?: { value?: string | null } | null, GARP_ID__c?: { value?: string | null } | null, Photo_URL__c?: { value?: string | null } | null } | null } | null> | null, pageInfo: { hasNextPage: boolean, endCursor?: string | null } } | null } } };

export type CurrentUserQueryVariables = Exact<{ [key: string]: never; }>;


export type CurrentUserQuery = { uiapi: { currentUser?: { Id: string, Name?: { value?: string | null } | null, Contact?: { Id: string, GARP_Member_ID__c?: { value?: string | null } | null, Photo_URL__c?: { value?: string | null } | null } | null } | null } };

export type SearchMemberDirectoryQueryVariables = Exact<{
  term: Scalars['String']['input'];
  first: Scalars['Int']['input'];
}>;


export type SearchMemberDirectoryQuery = { uiapi: { query: { Contact?: { edges?: Array<{ node?: { Id: string, Name?: { value?: string | null } | null, Company__c?: { value?: string | null } | null, MailingCountry?: { value?: string | null } | null, Corporate_Title__c?: { value?: string | null } | null, Job_Function__c?: { value?: string | null } | null } | null } | null> | null, pageInfo: { hasNextPage: boolean, endCursor?: string | null } } | null } } };

export type PersonalInfoCountriesQueryVariables = Exact<{
  first: Scalars['Int']['input'];
}>;


export type PersonalInfoCountriesQuery = { uiapi: { query: { Country_Code__c?: { edges?: Array<{ node?: { Id: string, Country__c?: { value?: string | null } | null, Name?: { value?: string | null } | null, PhoneCode__c?: { value?: string | null } | null } | null } | null> | null, pageInfo: { hasNextPage: boolean, endCursor?: string | null } } | null } } };

export type PersonalInfoEditContactQueryVariables = Exact<{
  contactId: Scalars['ID']['input'];
  first: Scalars['Int']['input'];
}>;


export type PersonalInfoEditContactQuery = { uiapi: { query: { Contact?: { edges?: Array<{ node?: { Id: string, FirstName?: { value?: string | null } | null, LastName?: { value?: string | null } | null, Email?: { value?: string | null } | null, MobilePhone?: { value?: string | null } | null, Mobile_Phone_Code__c?: { value?: string | null } | null, Photo_URL__c?: { value?: string | null } | null, Mailing_Address_Company__c?: { value?: string | null } | null, MailingStreet?: { value?: string | null } | null, MailingCity?: { value?: string | null } | null, MailingState?: { value?: string | null } | null, MailingPostalCode?: { value?: string | null } | null, MailingCountry?: { value?: string | null } | null, HomePhone?: { value?: string | null } | null, AccountId?: { value?: string | null } | null, Account?: { Id: string, Billing_Address_Company__c?: { value?: string | null } | null, BillingStreet?: { value?: string | null } | null, BillingCity?: { value?: string | null } | null, BillingState?: { value?: string | null } | null, BillingPostalCode?: { value?: string | null } | null, BillingCountry?: { value?: string | null } | null, Phone?: { value?: string | null } | null } | null } | null } | null> | null, pageInfo: { hasNextPage: boolean, endCursor?: string | null } } | null } } };

export type UploadProfilePhotoAttachmentMutationVariables = Exact<{
  parentId: Scalars['IdOrRef']['input'];
  name: Scalars['String']['input'];
  contentType: Scalars['String']['input'];
  body: Scalars['Base64']['input'];
}>;


export type UploadProfilePhotoAttachmentMutation = { uiapi: { AttachmentCreate?: { Record?: { Id: string } | null } | null } };

export type SetContactPhotoUrlMutationVariables = Exact<{
  contactId: Scalars['IdOrRef']['input'];
  photoUrl?: InputMaybe<Scalars['String']['input']>;
}>;


export type SetContactPhotoUrlMutation = { uiapi: { ContactUpdate?: { success?: boolean | null, Record?: { Photo_URL__c?: { value?: string | null } | null } | null } | null } };

export type SavePersonalInfoMutationVariables = Exact<{
  accountId: Scalars['IdOrRef']['input'];
  contactId: Scalars['IdOrRef']['input'];
  billingCompany?: InputMaybe<Scalars['String']['input']>;
  billingStreet?: InputMaybe<Scalars['TextArea']['input']>;
  billingCity?: InputMaybe<Scalars['String']['input']>;
  billingState?: InputMaybe<Scalars['String']['input']>;
  billingPostalCode?: InputMaybe<Scalars['String']['input']>;
  billingCountry?: InputMaybe<Scalars['String']['input']>;
  billingPhone?: InputMaybe<Scalars['PhoneNumber']['input']>;
  firstName?: InputMaybe<Scalars['String']['input']>;
  lastName?: InputMaybe<Scalars['String']['input']>;
  email?: InputMaybe<Scalars['Email']['input']>;
  mobilePhoneCode?: InputMaybe<Scalars['String']['input']>;
  mobilePhone?: InputMaybe<Scalars['PhoneNumber']['input']>;
  mailingCompany?: InputMaybe<Scalars['String']['input']>;
  mailingStreet?: InputMaybe<Scalars['TextArea']['input']>;
  mailingCity?: InputMaybe<Scalars['String']['input']>;
  mailingState?: InputMaybe<Scalars['String']['input']>;
  mailingPostalCode?: InputMaybe<Scalars['String']['input']>;
  mailingCountry?: InputMaybe<Scalars['String']['input']>;
  homePhone?: InputMaybe<Scalars['PhoneNumber']['input']>;
}>;


export type SavePersonalInfoMutation = { uiapi: { AccountUpdate?: { success?: boolean | null } | null, ContactUpdate?: { success?: boolean | null } | null } };
