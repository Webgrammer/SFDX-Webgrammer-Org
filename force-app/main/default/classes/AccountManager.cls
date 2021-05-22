
@RestResource(urlMapping='/accountmanager/*')
global with sharing class AccountManager {
    
    static final Integer errorCode = 400;
    static final Integer successCode = 200;

    global class ExternalAccount {
        global String name { get; set; }
        global String street { get; set; }
        global String city { get; set; }
        global String state { get; set; }
        global String country { get; set; }
        global String zipCode { get; set; }
        global String website { get; set; }
        global String phone { get; set; }
    }

    global class AccountManagerAPIResponse {
        global String message { get; set; }
        global Integer code { get; set; }
        global List<Account> accountsCreated { get; set; }
        global AccountManagerAPIResponse(){ message =  ''; code = 0 ; accountsCreated = new List<Account>(); }
    }

    global static Account parseAccount(ExternalAccount externalAccount){
        Account account = new Account();
        account.name = externalAccount.name;
        account.shippingCity = externalAccount.city;
        account.shippingStreet = externalAccount.street;
        account.shippingState = externalAccount.state;
        account.shippingCountry = externalAccount.country;
        account.shippingPostalCode = externalAccount.zipCode;
        account.phone = externalAccount.phone;
        account.website = externalAccount.website;
        return account;
    }

    @HttpPost
    global static AccountManagerAPIResponse createAccount(List<ExternalAccount> externalAccounts) {
        
        List<Account> parsedAccounts = new List<Account>();
        AccountManagerAPIResponse response = new AccountManagerAPIResponse();

        for(ExternalAccount externalAccount : externalAccounts){
            Account parsedAccount = parseAccount(externalAccount);
            parsedAccounts.add(parsedAccount);
        }
        try{
            Database.SaveResult[] insertResults = database.insert(parsedAccounts, true);
            response.message = 'Success';
            response.code = 200;
            for(Account parsedAccount : parsedAccounts){
                response.accountsCreated.add(parsedAccount);
            }
        }
        catch(Exception ex){
            response.message = ex.getMessage() + ex.getLineNumber();
            response.code = 400;
        }
        return response;
    }
}
