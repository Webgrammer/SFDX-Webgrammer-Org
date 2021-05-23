
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
        global String internal { get; set; }
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
        account.Internal_Account__c = (externalAccount.internal == 'true' ? true : false);
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
            response.code = successCode;
            for(Account parsedAccount : parsedAccounts){
                response.accountsCreated.add(parsedAccount);
            }
        }
        catch(Exception ex){
            response.message = ex.getMessage();
            response.code = errorCode;
        }
        return response;
    }

    @HttpGet
    global static AccountManagerAPIResponse getAccount(){
        
        String accountId = RestContext.request.params.get('id');
        List<Account> accounts = new List<Account>();

        AccountManagerAPIResponse accountResponse = new AccountManagerAPIResponse();

        if(accountId != null){
            accounts = [ SELECT ID, Name, ShippingCity, ShippingState, ShippingCountry,
            ShippingPostalCode, ShippingStreet, Phone, Website 
            FROM Account WHERE ID = :accountId AND Internal_Account__c = FALSE ];

            if(accounts.size() == 0){
                accountResponse.message = 'Error: The account does not exists or is not available for public API exposure.';
                accountResponse.code = errorCode;
            }
            else{
                accountResponse.message = 'Success';
                accountResponse.code = successCode;
                accountResponse.accountsCreated = accounts;
            }

        }
        else{
            accountResponse.message = 'Error: The account Id value was not provided.';
            accountResponse.code = errorCode;
        }

        return accountResponse;
    }
}
