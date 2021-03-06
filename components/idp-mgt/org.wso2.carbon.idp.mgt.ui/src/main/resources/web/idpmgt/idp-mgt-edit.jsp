<!--
~ Copyright (c) 2005-2014, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
~
~ WSO2 Inc. licenses this file to you under the Apache License,
~ Version 2.0 (the "License"); you may not use this file except
~ in compliance with the License.
~ You may obtain a copy of the License at
~
~ http://www.apache.org/licenses/LICENSE-2.0
~
~ Unless required by applicable law or agreed to in writing,
~ software distributed under the License is distributed on an
~ "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
~ KIND, either express or implied. See the License for the
~ specific language governing permissions and limitations
~ under the License.
-->

<%@page import="org.apache.axis2.context.ConfigurationContext" %>
<%@page import="org.wso2.carbon.CarbonConstants" %>
<%@page import="org.wso2.carbon.identity.application.common.model.CertData" %>
<%@page import="org.wso2.carbon.identity.application.common.model.idp.xsd.Claim" %>
<%@page import="org.wso2.carbon.identity.application.common.model.idp.xsd.ClaimMapping" %>
<%@page import="org.wso2.carbon.identity.application.common.model.idp.xsd.FederatedAuthenticatorConfig" %>

<%@page import="org.wso2.carbon.identity.application.common.model.idp.xsd.IdentityProvider" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="carbon" uri="http://wso2.org/projects/carbon/taglibs/carbontags.jar" %>
<%@ page import="org.wso2.carbon.identity.application.common.model.idp.xsd.Property" %>
<%@ page import="org.wso2.carbon.identity.application.common.model.idp.xsd.ProvisioningConnectorConfig" %>
<%@ page import="org.wso2.carbon.identity.application.common.model.idp.xsd.RoleMapping" %>
<%@ page import="org.wso2.carbon.identity.application.common.util.IdentityApplicationConstants" %>
<%@ page import="org.wso2.carbon.identity.application.common.util.IdentityApplicationManagementUtil" %>
<%@ page import="org.wso2.carbon.idp.mgt.ui.client.IdentityProviderMgtServiceClient" %>
<%@ page import="org.wso2.carbon.idp.mgt.ui.util.IdPManagementUIUtil" %>
<%@ page import="org.wso2.carbon.ui.CarbonUIUtil" %>
<%@ page import="org.wso2.carbon.ui.util.CharacterEncoder" %>
<%@ page import="org.wso2.carbon.utils.ServerConstants" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="org.wso2.carbon.user.core.util.UserCoreUtil" %>
<link href="css/idpmgt.css" rel="stylesheet" type="text/css" media="all"/>

<carbon:breadcrumb label="identity.providers" resourceBundle="org.wso2.carbon.idp.mgt.ui.i18n.Resources"
                   topPage="true" request="<%=request%>"/>
<jsp:include page="../dialog/display_messages.jsp"/>

<script type="text/javascript" src="../admin/js/main.js"></script>

<%
    String idPName = CharacterEncoder.getSafeText(request.getParameter("idPName"));
    if (idPName != null && idPName.equals("")) {
        idPName = null;
    }
    String realmId = null;
    String idpDisplayName = null;
    String description = null;
    boolean federationHubIdp = false;
    CertData certData = null;
    Claim[] identityProviderClaims = null;
    String userIdClaimURI = null;
    String roleClaimURI = null;
    String provisioningUserStoreIdClaimURI = null;
    ClaimMapping[] claimMappings = null;
    String[] roles = null;
    RoleMapping[] roleMappings = null;
    String idPAlias = null;
    boolean isProvisioningEnabled = false;
    boolean isCustomClaimEnabled = false;

    String provisioningUserStoreId = null;
    boolean isOpenIdEnabled = false;
    boolean isOpenIdDefault = false;
    boolean isAdvancedClaimConfigEnable = false;
    String openIdUrl = null;
    boolean isOpenIdUserIdInClaims = false;
    boolean isSAML2SSOEnabled = false;
    boolean isSAMLSSODefault = false;
    String idPEntityId = null;
    String spEntityId = null;
    String ssoUrl = null;
    boolean isAuthnRequestSigned = false;
    boolean isEnableAssertionEncription = false;
    boolean isEnableAssertionSigning = true;

    String requestMethod = "redirect";
    boolean isSLOEnabled = false;
    boolean isLogoutRequestSigned = false;
    String logoutUrl = null;
    boolean isAuthnResponseSigned = false;
    boolean isSAMLSSOUserIdInClaims = false;
    boolean isOIDCEnabled = false;
    boolean isOIDCDefault = false;
    String clientId = null;
    String clientSecret = null;
    String authzUrl = null;
    String tokenUrl = null;
    boolean isOIDCUserIdInClaims = false;
    boolean isPassiveSTSEnabled = false;
    boolean isPassiveSTSDefault = false;
    String passiveSTSRealm = null;
    String passiveSTSUrl = null;
    boolean isPassiveSTSUserIdInClaims = false;
    String[] userStoreDomains = null;
    boolean isFBAuthEnabled = false;
    boolean isFBAuthDefault = false;
    String fbClientId = null;
    String fbClientSecret = null;
    String fbScope = null;
    String fbUserInfoFields = null;
    boolean isFBUserIdInClaims = false;
    String fbAuthnEndpoint = null;
    String fbOauth2TokenEndpoint = null;
    String fbUserInfoEndpoint = null;


    // Claims
    String[] claimUris = new String[0];

    // Provisioning
    boolean isGoogleProvEnabled = false;
    boolean isGoogleProvDefault = false;
    String googleDomainName = null;
    String googleUserIDClaim = null;
    String googleUserIDDefaultValue = null;
    String googleFamilyNameClaim = null;
    String googleFamilyNameDefaultValue = null;
    String googleGivenNameClaim = null;
    String googleGivenNameDefaultValue = null;
    String googlePasswordClaim = null;
    String googlePasswordDefaultValue = null;
    String googlePrimaryEmailClaim = null;
    String googlePrimaryEmailDefaultValue = null;
    String googleProvServiceAccEmail = null;
    String googleProvAdminEmail = null;
    String googleProvApplicationName = null;
    String googleProvPattern = null;
    String googleProvisioningSeparator = null;
    String googleProvPrivateKeyData = null;

    boolean isSfProvEnabled = false;
    boolean isSfProvDefault = false;
    String sfApiVersion = null;
    String sfDomainName = null;
    String sfClientId = null;
    String sfClientSecret = null;
    String sfUserName = null;
    String sfProvPattern = null;
    String sfProvSeparator = null;
    String sfProvDomainName = null;
    String sfPassword = null;
    String sfOauth2TokenEndpoint = null;

    boolean isScimProvEnabled = false;
    boolean isScimProvDefault = false;
    String scimUserName = null;
    String scimPassword = null;
    String scimGroupEp = null;
    String scimUserEp = null;
    String scimUserStoreDomain = null;

    boolean isSpmlProvEnabled = false;
    boolean isSpmlProvDefault = false;
    String spmlUserName = null;
    String spmlPassword = null;
    String spmlEndpoint = null;
    String spmlObjectClass = null;

    String oidcQueryParam = "";
    String samlQueryParam = "";
    String passiveSTSQueryParam = "";
    String openidQueryParam = "";

    String provisioningRole = null;
    Map<String, ProvisioningConnectorConfig> customProvisioningConnectors = null;


    String[] idpClaims = new String[]{"admin", "Internal/everyone"};//appBean.getSystemClaims();

    IdentityProvider identityProvider = (IdentityProvider) session.getAttribute("identityProvider");
    List<IdentityProvider> identityProvidersList = (List<IdentityProvider>) session.getAttribute("identityProviderList");

    Map<String, FederatedAuthenticatorConfig> allFedAuthConfigs = new HashMap<String, FederatedAuthenticatorConfig>();

    String cookie = (String) session.getAttribute(ServerConstants.ADMIN_SERVICE_COOKIE);
    String backendServerURL = CarbonUIUtil.getServerURL(config.getServletContext(), session);
    ConfigurationContext configContext =
            (ConfigurationContext) config.getServletContext().getAttribute(CarbonConstants.CONFIGURATION_CONTEXT);
    IdentityProviderMgtServiceClient client = new IdentityProviderMgtServiceClient(cookie, backendServerURL, configContext);

    allFedAuthConfigs = client.getAllFederatedAuthenticators();
    customProvisioningConnectors = client.getCustomProvisioningConnectors();

    if (identityProvidersList == null) {
%>
<script type="text/javascript">
    location.href = "idp-mgt-list-load.jsp?callback=idp-mgt-edit.jsp";
</script>
<%
        return;
    }
    if (idPName != null && identityProvider != null) {
        idPName = identityProvider.getIdentityProviderName();
        federationHubIdp = identityProvider.getFederationHub();
        realmId = identityProvider.getHomeRealmId();
        idpDisplayName = identityProvider.getDisplayName();
        description = identityProvider.getIdentityProviderDescription();
        provisioningRole = identityProvider.getProvisioningRole();
        if (StringUtils.isNotBlank(identityProvider.getCertificate())) {
            certData = IdentityApplicationManagementUtil.getCertData(identityProvider.getCertificate());
        }

        identityProviderClaims = identityProvider.getClaimConfig().getIdpClaims();

        userIdClaimURI = identityProvider.getClaimConfig().getUserClaimURI();
        roleClaimURI = identityProvider.getClaimConfig().getRoleClaimURI();
        provisioningUserStoreIdClaimURI = identityProvider.getJustInTimeProvisioningConfig().getUserStoreClaimUri();

        claimMappings = identityProvider.getClaimConfig().getClaimMappings();

        if (identityProviderClaims != null && identityProviderClaims.length != 0) {
            isCustomClaimEnabled = true;
        } else {
            isCustomClaimEnabled = false;
        }


        roles = identityProvider.getPermissionAndRoleConfig().getIdpRoles();
        roleMappings = identityProvider.getPermissionAndRoleConfig().getRoleMappings();

        FederatedAuthenticatorConfig[] fedAuthnConfigs = identityProvider.getFederatedAuthenticatorConfigs();

        if (fedAuthnConfigs != null && fedAuthnConfigs.length > 0) {
            for (FederatedAuthenticatorConfig fedAuthnConfig : fedAuthnConfigs) {
                if (fedAuthnConfig.getProperties() == null) {
                    fedAuthnConfig.setProperties(new Property[0]);
                }
                if (fedAuthnConfig.getDisplayName().equals(IdentityApplicationConstants.Authenticator.OpenID.NAME)) {
                    allFedAuthConfigs.remove(fedAuthnConfig.getName());
                    isOpenIdEnabled = fedAuthnConfig.getEnabled();

                    Property openIdUrlProp = IdPManagementUIUtil.getProperty(fedAuthnConfig.getProperties(),
                            IdentityApplicationConstants.Authenticator.OpenID.OPEN_ID_URL);
                    if (openIdUrlProp != null) {
                        openIdUrl = openIdUrlProp.getValue();
                    }

                    Property queryParamProp = IdPManagementUIUtil.getProperty(fedAuthnConfig.getProperties(), "commonAuthQueryParams");
                    if (queryParamProp != null) {
                        openidQueryParam = queryParamProp.getValue();
                    }

                    if (openIdUrlProp != null) {
                        openIdUrl = openIdUrlProp.getValue();
                    }

                    Property isOpenIdUserIdInClaimsProp = IdPManagementUIUtil.getProperty(fedAuthnConfig.getProperties(),
                            IdentityApplicationConstants.Authenticator.OpenID.IS_USER_ID_IN_CLAIMS);
                    if (isOpenIdUserIdInClaimsProp != null) {
                        isOpenIdUserIdInClaims = Boolean.parseBoolean(isOpenIdUserIdInClaimsProp.getValue());
                    }
                } else if (fedAuthnConfig.getDisplayName().equals(IdentityApplicationConstants.Authenticator.Facebook.NAME)) {
                    allFedAuthConfigs.remove(fedAuthnConfig.getName());
                    isFBAuthEnabled = fedAuthnConfig.getEnabled();
                    Property fbClientIdProp = IdPManagementUIUtil.getProperty(fedAuthnConfig.getProperties(),
                            IdentityApplicationConstants.Authenticator.Facebook.CLIENT_ID);
                    if (fbClientIdProp != null) {
                        fbClientId = fbClientIdProp.getValue();
                    }
                    Property fbClientSecretProp = IdPManagementUIUtil.getProperty(fedAuthnConfig.getProperties(),
                            IdentityApplicationConstants.Authenticator.Facebook.CLIENT_SECRET);
                    if (fbClientSecretProp != null) {
                        fbClientSecret = fbClientSecretProp.getValue();
                    }
                    Property fbScopeProp = IdPManagementUIUtil
                            .getProperty(fedAuthnConfig.getProperties(),
                                    IdentityApplicationConstants.Authenticator.Facebook.SCOPE);
                    if (fbScopeProp != null) {
                        fbScope = fbScopeProp.getValue();
                    }
                    Property fbUserInfoFieldsProp = IdPManagementUIUtil.getProperty(fedAuthnConfig.getProperties(),
                            IdentityApplicationConstants.Authenticator.Facebook.USER_INFO_FIELDS);
                    if (fbUserInfoFieldsProp != null) {
                        fbUserInfoFields = fbUserInfoFieldsProp.getValue();
                    }
                    Property fbAuthnEndpointProp = IdPManagementUIUtil
                            .getProperty(fedAuthnConfig.getProperties(),
                                    IdentityApplicationConstants.Authenticator.Facebook.AUTH_ENDPOINT);
                    if (fbAuthnEndpointProp != null) {
                        fbAuthnEndpoint = fbAuthnEndpointProp.getValue();
                    }
                    Property fbOauth2TokenEndpointProp = IdPManagementUIUtil
                            .getProperty(fedAuthnConfig.getProperties(),
                                    IdentityApplicationConstants.Authenticator.Facebook.AUTH_TOKEN_ENDPOINT);
                    if (fbOauth2TokenEndpointProp != null) {
                        fbOauth2TokenEndpoint = fbOauth2TokenEndpointProp.getValue();
                    }
                    Property fbUserInfoEndpointProp = IdPManagementUIUtil
                            .getProperty(fedAuthnConfig.getProperties(),
                                    IdentityApplicationConstants.Authenticator.Facebook.USER_INFO_ENDPOINT);
                    if (fbUserInfoEndpointProp != null) {
                        fbUserInfoEndpoint = fbUserInfoEndpointProp.getValue();
                    }
                } else if (fedAuthnConfig.getDisplayName().equals(IdentityApplicationConstants.Authenticator.PassiveSTS.NAME)) {
                    allFedAuthConfigs.remove(fedAuthnConfig.getName());
                    isPassiveSTSEnabled = fedAuthnConfig.getEnabled();
                    Property passiveSTSRealmProp = IdPManagementUIUtil.getProperty(fedAuthnConfig.getProperties(),
                            IdentityApplicationConstants.Authenticator.PassiveSTS.REALM_ID);
                    if (passiveSTSRealmProp != null) {
                        passiveSTSRealm = passiveSTSRealmProp.getValue();
                    }
                    Property passiveSTSUrlProp = IdPManagementUIUtil.getProperty(fedAuthnConfig.getProperties(),
                            IdentityApplicationConstants.Authenticator.PassiveSTS.IDENTITY_PROVIDER_URL);
                    if (passiveSTSUrlProp != null) {
                        passiveSTSUrl = passiveSTSUrlProp.getValue();
                    }
                    Property isPassiveSTSUserIdInClaimsProp = IdPManagementUIUtil.getProperty(fedAuthnConfig.getProperties(),
                            IdentityApplicationConstants.Authenticator.PassiveSTS.IS_USER_ID_IN_CLAIMS);
                    if (isPassiveSTSUserIdInClaimsProp != null) {
                        isPassiveSTSUserIdInClaims = Boolean.parseBoolean(isPassiveSTSUserIdInClaimsProp.getValue());
                    }

                    Property queryParamProp = IdPManagementUIUtil.getProperty(fedAuthnConfig.getProperties(), "commonAuthQueryParams");
                    if (queryParamProp != null) {
                        passiveSTSQueryParam = queryParamProp.getValue();
                    }

                } else if (fedAuthnConfig.getDisplayName().equals(IdentityApplicationConstants.Authenticator.OIDC.NAME)) {
                    allFedAuthConfigs.remove(fedAuthnConfig.getName());
                    isOIDCEnabled = fedAuthnConfig.getEnabled();
                    Property authzUrlProp = IdPManagementUIUtil.getProperty(fedAuthnConfig.getProperties(),
                            IdentityApplicationConstants.Authenticator.OIDC.OAUTH2_AUTHZ_URL);
                    if (authzUrlProp != null) {
                        authzUrl = authzUrlProp.getValue();
                    }
                    Property tokenUrlProp = IdPManagementUIUtil.getProperty(fedAuthnConfig.getProperties(),
                            IdentityApplicationConstants.Authenticator.OIDC.OAUTH2_TOKEN_URL);
                    if (tokenUrlProp != null) {
                        tokenUrl = tokenUrlProp.getValue();
                    }
                    Property clientIdProp = IdPManagementUIUtil.getProperty(fedAuthnConfig.getProperties(),
                            IdentityApplicationConstants.Authenticator.OIDC.CLIENT_ID);
                    if (clientIdProp != null) {
                        clientId = clientIdProp.getValue();
                    }
                    Property clientSecretProp = IdPManagementUIUtil.getProperty(fedAuthnConfig.getProperties(),
                            IdentityApplicationConstants.Authenticator.OIDC.CLIENT_SECRET);
                    if (clientSecretProp != null) {
                        clientSecret = clientSecretProp.getValue();
                    }
                    Property isOIDCUserIdInClaimsProp = IdPManagementUIUtil.getProperty(fedAuthnConfig.getProperties(),
                            IdentityApplicationConstants.Authenticator.OIDC.IS_USER_ID_IN_CLAIMS);
                    if (isOIDCUserIdInClaimsProp != null) {
                        isOIDCUserIdInClaims = Boolean.parseBoolean(isOIDCUserIdInClaimsProp.getValue());
                    }

                    Property queryParamProp = IdPManagementUIUtil.getProperty(fedAuthnConfig.getProperties(), "commonAuthQueryParams");
                    if (queryParamProp != null) {
                        oidcQueryParam = queryParamProp.getValue();
                    }

                } else if (fedAuthnConfig.getDisplayName().equals(IdentityApplicationConstants.Authenticator.SAML2SSO.NAME)) {
                    allFedAuthConfigs.remove(fedAuthnConfig.getName());
                    isSAML2SSOEnabled = fedAuthnConfig.getEnabled();
                    Property idPEntityIdProp = IdPManagementUIUtil.getProperty(fedAuthnConfig.getProperties(),
                            IdentityApplicationConstants.Authenticator.SAML2SSO.IDP_ENTITY_ID);
                    if (idPEntityIdProp != null) {
                        idPEntityId = idPEntityIdProp.getValue();
                    }
                    Property spEntityIdProp = IdPManagementUIUtil.getProperty(fedAuthnConfig.getProperties(),
                            IdentityApplicationConstants.Authenticator.SAML2SSO.SP_ENTITY_ID);
                    if (spEntityIdProp != null) {
                        spEntityId = spEntityIdProp.getValue();
                    }
                    Property ssoUrlProp = IdPManagementUIUtil.getProperty(fedAuthnConfig.getProperties(),
                            IdentityApplicationConstants.Authenticator.SAML2SSO.SSO_URL);
                    if (spEntityIdProp != null) {
                        ssoUrl = ssoUrlProp.getValue();
                    }
                    Property isAuthnRequestSignedProp = IdPManagementUIUtil.getProperty(fedAuthnConfig.getProperties(),
                            IdentityApplicationConstants.Authenticator.SAML2SSO.IS_AUTHN_REQ_SIGNED);
                    if (isAuthnRequestSignedProp != null) {
                        isAuthnRequestSigned = Boolean.parseBoolean(isAuthnRequestSignedProp.getValue());
                    }

                    Property isEnableAssertionSigningProp = IdPManagementUIUtil.getProperty(fedAuthnConfig.getProperties(),
                            IdentityApplicationConstants.Authenticator.SAML2SSO.IS_ENABLE_ASSERTION_SIGNING);
                    if (isEnableAssertionSigningProp != null) {
                        isEnableAssertionSigning = Boolean.parseBoolean(isEnableAssertionSigningProp.getValue());
                    }

                    Property isEnableAssersionEncriptionProp = IdPManagementUIUtil.getProperty(fedAuthnConfig.getProperties(),
                            IdentityApplicationConstants.Authenticator.SAML2SSO.IS_ENABLE_ASSERTION_ENCRYPTION);
                    if (isEnableAssersionEncriptionProp != null) {
                        isEnableAssertionEncription = Boolean.parseBoolean(isEnableAssersionEncriptionProp.getValue());
                    }

                    Property isSLOEnabledProp = IdPManagementUIUtil.getProperty(fedAuthnConfig.getProperties(),
                            IdentityApplicationConstants.Authenticator.SAML2SSO.IS_LOGOUT_ENABLED);
                    if (isSLOEnabledProp != null) {
                        isSLOEnabled = Boolean.parseBoolean(isSLOEnabledProp.getValue());
                    }
                    Property logoutUrlProp = IdPManagementUIUtil.getProperty(fedAuthnConfig.getProperties(),
                            IdentityApplicationConstants.Authenticator.SAML2SSO.LOGOUT_REQ_URL);
                    if (logoutUrlProp != null) {
                        logoutUrl = logoutUrlProp.getValue();
                    }
                    Property isLogoutRequestSignedProp = IdPManagementUIUtil.getProperty(fedAuthnConfig.getProperties(),
                            IdentityApplicationConstants.Authenticator.SAML2SSO.IS_LOGOUT_REQ_SIGNED);
                    if (isLogoutRequestSignedProp != null) {
                        isLogoutRequestSigned = Boolean.parseBoolean(isLogoutRequestSignedProp.getValue());
                    }
                    Property isAuthnResponseSignedProp = IdPManagementUIUtil.getProperty(fedAuthnConfig.getProperties(),
                            IdentityApplicationConstants.Authenticator.SAML2SSO.IS_AUTHN_RESP_SIGNED);
                    if (isAuthnResponseSignedProp != null) {
                        isAuthnResponseSigned = Boolean.parseBoolean(isAuthnResponseSignedProp.getValue());
                    }

                    Property requestMethodProp = IdPManagementUIUtil.getProperty(fedAuthnConfig.getProperties(),
                            IdentityApplicationConstants.Authenticator.SAML2SSO.REQUEST_METHOD);
                    if (requestMethodProp != null) {
                        requestMethod = requestMethodProp.getValue();
                    } else {
                        requestMethod = "redirect";
                    }

                    Property isSAMLSSOUserIdInClaimsProp = IdPManagementUIUtil.getProperty(fedAuthnConfig.getProperties(),
                            IdentityApplicationConstants.Authenticator.SAML2SSO.IS_USER_ID_IN_CLAIMS);
                    if (isSAMLSSOUserIdInClaimsProp != null) {
                        isSAMLSSOUserIdInClaims = Boolean.parseBoolean(isSAMLSSOUserIdInClaimsProp.getValue());
                    }

                    Property queryParamProp = IdPManagementUIUtil.getProperty(fedAuthnConfig.getProperties(), "commonAuthQueryParams");
                    if (queryParamProp != null) {
                        samlQueryParam = queryParamProp.getValue();
                    }

                } else {
                    FederatedAuthenticatorConfig customConfig = allFedAuthConfigs.get(fedAuthnConfig.getName());
                    if (customConfig != null) {
                        Property[] properties = fedAuthnConfig.getProperties();
                        Property[] customProperties = customConfig.getProperties();

                        if (properties != null && properties.length > 0 && customProperties != null && customProperties.length > 0) {
                            for (Property property : properties) {
                                for (Property customProperty : customProperties) {
                                    if (property.getName().equals(customProperty.getName())) {
                                        customProperty.setValue(property.getValue());
                                        break;
                                    }
                                }
                            }
                        }

                        customConfig.setEnabled(fedAuthnConfig.getEnabled());
                        allFedAuthConfigs.put(fedAuthnConfig.getName(), customConfig);
                    }

                }
            }
        }


        idPAlias = identityProvider.getAlias();
        isProvisioningEnabled = identityProvider.getJustInTimeProvisioningConfig().getProvisioningEnabled();
        provisioningUserStoreId = identityProvider.getJustInTimeProvisioningConfig().getProvisioningUserStore();

        if (identityProvider.getDefaultAuthenticatorConfig() != null
                && identityProvider.getDefaultAuthenticatorConfig().getName() != null) {
            isOpenIdDefault = identityProvider.getDefaultAuthenticatorConfig().getDisplayName().equals(
                    IdentityApplicationConstants.Authenticator.OpenID.NAME);
        }

        if (identityProvider.getDefaultAuthenticatorConfig() != null
                && identityProvider.getDefaultAuthenticatorConfig().getName() != null) {
            isSAMLSSODefault = identityProvider.getDefaultAuthenticatorConfig().getDisplayName().equals(
                    IdentityApplicationConstants.Authenticator.SAML2SSO.NAME);
        }

        if (identityProvider.getDefaultAuthenticatorConfig() != null
                && identityProvider.getDefaultAuthenticatorConfig().getName() != null) {
            isOIDCDefault = identityProvider.getDefaultAuthenticatorConfig().getDisplayName().equals(
                    IdentityApplicationConstants.Authenticator.OIDC.NAME);
        }

        if (identityProvider.getDefaultAuthenticatorConfig() != null
                && identityProvider.getDefaultAuthenticatorConfig().getName() != null) {
            isPassiveSTSDefault = identityProvider.getDefaultAuthenticatorConfig().getDisplayName().equals(
                    IdentityApplicationConstants.Authenticator.PassiveSTS.NAME);
        }

        if (identityProvider.getDefaultAuthenticatorConfig() != null
                && identityProvider.getDefaultAuthenticatorConfig().getName() != null) {
            isFBAuthDefault = identityProvider.getDefaultAuthenticatorConfig().getDisplayName().equals(
                    IdentityApplicationConstants.Authenticator.Facebook.NAME);
        }

        ProvisioningConnectorConfig[] provisioningConnectors = identityProvider.getProvisioningConnectorConfigs();

        ProvisioningConnectorConfig googleApps = null;
        ProvisioningConnectorConfig salesforce = null;
        ProvisioningConnectorConfig scim = null;
        ProvisioningConnectorConfig spml = null;

        if (provisioningConnectors != null) {
            for (ProvisioningConnectorConfig provisioningConnector : provisioningConnectors) {
                if (provisioningConnector != null && "scim".equals(provisioningConnector.getName())) {
                    scim = provisioningConnector;
                } else if (provisioningConnector != null && "spml".equals(provisioningConnector.getName())) {
                    spml = provisioningConnector;
                } else if (provisioningConnector != null && "salesforce".equals(provisioningConnector.getName())) {
                    salesforce = provisioningConnector;
                } else if (provisioningConnector != null && "googleapps".equals(provisioningConnector.getName())) {
                    googleApps = provisioningConnector;
                } else {
                    if (customProvisioningConnectors.containsKey(provisioningConnector.getName())) {

                        ProvisioningConnectorConfig customConfig = customProvisioningConnectors.get(provisioningConnector.getName());
                        Property[] properties = provisioningConnector.getProvisioningProperties();
                        Property[] customProperties = customConfig.getProvisioningProperties();

                        customConfig.setEnabled(provisioningConnector.getEnabled());

                        if (properties != null && properties.length > 0 && customProperties != null && customProperties.length > 0) {
                            for (Property property : properties) {
                                for (Property customProperty : customProperties) {
                                    if (property.getName().equals(customProperty.getName())) {
                                        customProperty.setValue(property.getValue());
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        if (salesforce != null) {

            if (identityProvider.getDefaultProvisioningConnectorConfig() != null
                    && identityProvider.getDefaultProvisioningConnectorConfig().getName() != null) {
                isSfProvDefault = identityProvider.getDefaultProvisioningConnectorConfig().getName().equals(salesforce.getName());
            }

            Property[] sfProperties = salesforce.getProvisioningProperties();
            if (sfProperties != null && sfProperties.length > 0) {
                for (Property sfProperty : sfProperties) {
                    if ("sf-api-version".equals(sfProperty.getName())) {
                        sfApiVersion = sfProperty.getValue();
                    } else if ("sf-domain-name".equals(sfProperty.getName())) {
                        sfDomainName = sfProperty.getValue();
                    } else if ("sf-clientid".equals(sfProperty.getName())) {
                        sfClientId = sfProperty.getValue();
                    } else if ("sf-client-secret".equals(sfProperty.getName())) {
                        sfClientSecret = sfProperty.getValue();
                    } else if ("sf-username".equals(sfProperty.getName())) {
                        sfUserName = sfProperty.getValue();
                    } else if ("sf-password".equals(sfProperty.getName())) {
                        sfPassword = sfProperty.getValue();
                    } else if ("sf-token-endpoint".equals(sfProperty.getName())) {
                        sfOauth2TokenEndpoint = sfProperty.getValue();
                    } else if ("sf-prov-pattern".equals(sfProperty.getName())) {
                        sfProvPattern = sfProperty.getValue();
                    } else if ("sf-prov-separator".equals(sfProperty.getName())) {
                        sfProvSeparator = sfProperty.getValue();
                    } else if ("sf-prov-domainName".equals(sfProperty.getName())) {
                        sfProvDomainName = sfProperty.getValue();
                    }
                }
            }
            if (salesforce.getEnabled()) {
                isSfProvEnabled = true;
            }

        }

        if (scim != null) {

            if (identityProvider.getDefaultProvisioningConnectorConfig() != null
                    && identityProvider.getDefaultProvisioningConnectorConfig().getName() != null) {
                isScimProvDefault = identityProvider.getDefaultProvisioningConnectorConfig().getName().equals(scim.getName());
            }

            Property[] scimProperties = scim.getProvisioningProperties();
            if (scimProperties != null && scimProperties.length > 0) {
                for (Property scimProperty : scimProperties) {
                    if ("scim-username".equals(scimProperty.getName())) {
                        scimUserName = scimProperty.getValue();
                    } else if ("scim-password".equals(scimProperty.getName())) {
                        scimPassword = scimProperty.getValue();
                    } else if ("scim-user-ep".equals(scimProperty.getName())) {
                        scimUserEp = scimProperty.getValue();
                    } else if ("scim-group-ep".equals(scimProperty.getName())) {
                        scimGroupEp = scimProperty.getValue();
                    } else if ("scim-user-store-domain".equals(scimProperty.getName())) {
                        scimUserStoreDomain = scimProperty.getValue();
                    }
                }
            }

            if (scim.getEnabled()) {
                isScimProvEnabled = true;
            }

        }

        // Provisioning
        isGoogleProvEnabled = false;
        isGoogleProvDefault = false;
        googleDomainName = "";
        googleUserIDClaim = "";
        googleUserIDDefaultValue = "";
        googleFamilyNameClaim = "";
        googleFamilyNameDefaultValue = "";
        googleGivenNameClaim = "";
        googleGivenNameDefaultValue = "";
        googlePasswordClaim = "";
        googlePasswordDefaultValue = "";
        googlePrimaryEmailClaim = "";
        googlePrimaryEmailDefaultValue = "";
        googleProvServiceAccEmail = "";
        googleProvAdminEmail = "";
        googleProvApplicationName = "";
        googleProvPattern = "";
        googleProvisioningSeparator = "";
        //if(identityProvider.getCertificate() != null){
        //    googleProvPrivateKeyData = IdPMgtUtil.getCertData(identityProvider.getCertificate());
        //}
        //idpClaims = identityProvider.getSystemClaims();


        if (googleApps != null) {

            if (identityProvider.getDefaultProvisioningConnectorConfig() != null
                    && identityProvider.getDefaultProvisioningConnectorConfig().getName() != null) {
                isGoogleProvDefault = identityProvider.getDefaultProvisioningConnectorConfig().getName().equals(googleApps.getName());
            }

            Property[] googleProperties = googleApps.getProvisioningProperties();
            if (googleProperties != null && googleProperties.length > 0) {
                for (Property googleProperty : googleProperties) {
                    if ("google_prov_domain_name".equals(googleProperty.getName())) {
                        googleDomainName = googleProperty.getValue();
                    } else if ("google_prov_givenname".equals(googleProperty.getName())) {
                        googleGivenNameDefaultValue = googleProperty.getValue();
                    } else if ("google_prov_familyname".equals(googleProperty.getName())) {
                        googleFamilyNameDefaultValue = googleProperty.getValue();
                    } else if ("google_prov_service_acc_email".equals(googleProperty.getName())) {
                        googleProvServiceAccEmail = googleProperty.getValue();
                    } else if ("google_prov_admin_email".equals(googleProperty.getName())) {
                        googleProvAdminEmail = googleProperty.getValue();
                    } else if ("google_prov_application_name".equals(googleProperty.getName())) {
                        googleProvApplicationName = googleProperty.getValue();
                    } else if ("google_prov_email_claim_dropdown".equals(googleProperty.getName())) {
                        googlePrimaryEmailClaim = googleProperty.getValue();
                    } else if ("google_prov_givenname_claim_dropdown".equals(googleProperty.getName())) {
                        googleGivenNameClaim = googleProperty.getValue();
                    } else if ("google_prov_familyname_claim_dropdown".equals(googleProperty.getName())) {
                        googleFamilyNameClaim = googleProperty.getValue();
                    } else if ("google_prov_private_key".equals(googleProperty.getName())) {
                        googleProvPrivateKeyData = googleProperty.getValue();
                    } else if ("google_prov_pattern".equals(googleProperty.getName())) {
                        googleProvPattern = googleProperty.getValue();
                    } else if ("google_prov_separator".equals(googleProperty.getName())) {
                        googleProvisioningSeparator = googleProperty.getValue();
                    }


                }
            }

            if (googleApps.getEnabled()) {
                isGoogleProvEnabled = true;
            }

        }

        if (spml != null) {

            if (identityProvider.getDefaultProvisioningConnectorConfig() != null
                    && identityProvider.getDefaultProvisioningConnectorConfig().getName() != null) {
                isSpmlProvDefault = identityProvider.getDefaultProvisioningConnectorConfig().getName().equals(spml.getName());
            }

            Property[] spmlProperties = spml.getProvisioningProperties();
            if (spmlProperties != null && spmlProperties.length > 0) {
                for (Property spmlProperty : spmlProperties) {
                    if ("spml-username".equals(spmlProperty.getName())) {
                        spmlUserName = spmlProperty.getValue();
                    } else if ("spml-password".equals(spmlProperty.getName())) {
                        spmlPassword = spmlProperty.getValue();
                    } else if ("spml-ep".equals(spmlProperty.getName())) {
                        spmlEndpoint = spmlProperty.getValue();
                    } else if ("spml-oc".equals(spmlProperty.getName())) {
                        spmlObjectClass = spmlProperty.getValue();
                    }
                }
            }

            if (spml.getEnabled()) {
                isSpmlProvEnabled = true;
            }

        }

    }

    if (idPName == null) {
        idPName = "";
    }

    if (realmId == null) {
        realmId = "";
    }

    if (idpDisplayName == null) {
        idpDisplayName = "";
    }
    if (description == null) {
        description = "";
    }

    if (provisioningRole == null) {
        provisioningRole = "";
    }

    if (passiveSTSQueryParam == null) {
        passiveSTSQueryParam = "";
    }

    if (oidcQueryParam == null) {
        oidcQueryParam = "";
    }
    if (idPAlias == null) {
        idPAlias = IdPManagementUIUtil.getOAuth2TokenEPURL(request);
        ;
    }
    String provisionStaticDropdownDisabled = "";
    String provisionDynamicDropdownDisabled = "";
    if (!isProvisioningEnabled) {
        provisionStaticDropdownDisabled = "disabled=\'disabled\'";
        provisionDynamicDropdownDisabled = "disabled=\'disabled\'";
    } else if (isProvisioningEnabled && provisioningUserStoreId != null) {
        provisionDynamicDropdownDisabled = "disabled=\'disabled\'";
    } else if (isProvisioningEnabled && provisioningUserStoreId == null) {
        provisionStaticDropdownDisabled = "disabled=\'disabled\'";
    }

    userStoreDomains = client.getUserStoreDomains();

    claimUris = client.getAllLocalClaimUris();

    String openIdEnabledChecked = "";
    String openIdDefaultDisabled = "";
    if (identityProvider != null) {
        if (isOpenIdEnabled) {
            openIdEnabledChecked = "checked=\'checked\'";
        } else {
            openIdDefaultDisabled = "disabled=\'disabled\'";
        }
    }
    String openIdDefaultChecked = "";

    if (identityProvider != null) {
        if (isOpenIdDefault) {
            openIdDefaultChecked = "checked=\'checked\'";
            openIdDefaultDisabled = "disabled=\'disabled\'";
        }
    }
    if (openIdUrl == null) {
        openIdUrl = IdPManagementUIUtil.getOpenIDUrl(request);
    }
    String saml2SSOEnabledChecked = "";
    String saml2SSODefaultDisabled = "";
    if (identityProvider != null) {
        if (isSAML2SSOEnabled) {
            saml2SSOEnabledChecked = "checked=\'checked\'";
        } else {
            saml2SSODefaultDisabled = "disabled=\'disabled\'";
        }
    }
    String saml2SSODefaultChecked = "";
    if (identityProvider != null) {
        if (isSAMLSSODefault) {
            saml2SSODefaultChecked = "checked=\'checked\'";
            saml2SSODefaultDisabled = "disabled=\'disabled\'";
        }
    }
    if (idPEntityId == null) {
        idPEntityId = "";
    }
    if (spEntityId == null) {
        spEntityId = "";
    }
    if (ssoUrl == null) {
        ssoUrl = IdPManagementUIUtil.getSAML2SSOUrl(request);
    }
    String authnRequestSignedChecked = "";
    if (identityProvider != null) {
        if (isAuthnRequestSigned) {
            authnRequestSignedChecked = "checked=\'checked\'";
        }
    }

    String enableAssertinEncriptionChecked = "";
    if (identityProvider != null) {
        if (isEnableAssertionEncription) {
            enableAssertinEncriptionChecked = "checked=\'checked\'";
        }
    }

    String enableAssertionSigningChecked = "";
    if (identityProvider != null) {
        if (isEnableAssertionSigning) {
            enableAssertionSigningChecked = "checked=\'checked\'";
        }
    }

    String sloEnabledChecked = "";
    if (identityProvider != null) {
        if (isSLOEnabled) {
            sloEnabledChecked = "checked=\'checked\'";
        }
    }
    if (logoutUrl == null) {
        logoutUrl = "";
    }
    String logoutRequestSignedChecked = "";
    if (identityProvider != null) {
        if (isLogoutRequestSigned) {
            logoutRequestSignedChecked = "checked=\'checked\'";
        }
    }
    String authnResponseSignedChecked = "";
    if (identityProvider != null) {
        if (isAuthnResponseSigned) {
            authnResponseSignedChecked = "checked=\'checked\'";
        }
    }
    String oidcEnabledChecked = "";
    String oidcDefaultDisabled = "";
    if (identityProvider != null) {
        if (isOIDCEnabled) {
            oidcEnabledChecked = "checked=\'checked\'";
        } else {
            oidcDefaultDisabled = "disabled=\'disabled\'";
        }
    }
    String oidcDefaultChecked = "";

    if (identityProvider != null) {
        if (isOIDCDefault) {
            oidcDefaultChecked = "checked=\'checked\'";
            oidcDefaultDisabled = "disabled=\'disabled\'";
        }
    }
    if (authzUrl == null) {
        authzUrl = IdPManagementUIUtil.getOAuth2AuthzEPURL(request);
    }
    if (tokenUrl == null) {
        tokenUrl = IdPManagementUIUtil.getOAuth2TokenEPURL(request);
    }
    if (clientId == null) {
        clientId = "";
    }
    if (clientSecret == null) {
        clientSecret = "";
    }
    String passiveSTSEnabledChecked = "";
    String passiveSTSDefaultDisabled = "";
    if (identityProvider != null) {
        if (isPassiveSTSEnabled) {
            passiveSTSEnabledChecked = "checked=\'checked\'";
        } else {
            passiveSTSDefaultDisabled = "disabled=\'disabled\'";
        }
    }
    String passiveSTSDefaultChecked = "";
    if (identityProvider != null) {
        if (isPassiveSTSDefault) {
            passiveSTSDefaultChecked = "checked=\'checked\'";
            passiveSTSDefaultDisabled = "disabled=\'disabled\'";
        }
    }
    if (passiveSTSRealm == null) {
        passiveSTSRealm = "";
    }
    if (passiveSTSUrl == null) {
        passiveSTSUrl = IdPManagementUIUtil.getPassiveSTSURL(request);
    }
    String fbAuthEnabledChecked = "";
    String fbAuthDefaultDisabled = "";

    if (identityProvider != null) {
        if (isFBAuthEnabled) {
            fbAuthEnabledChecked = "checked=\'checked\'";
        } else {
            fbAuthDefaultDisabled = "disabled=\'disabled\'";
        }
    }
    String fbAuthDefaultChecked = "";
    if (identityProvider != null) {
        if (isFBAuthDefault) {
            fbAuthDefaultChecked = "checked=\'checked\'";
            fbAuthDefaultDisabled = "disabled=\'disabled\'";
        }
    }
    if (fbClientId == null) {
        fbClientId = "";
    }
    if (fbClientSecret == null) {
        fbClientSecret = "";
    }
    if (fbScope == null) {
        fbScope = "email";
    }
    if (fbUserInfoFields == null) {
        fbUserInfoFields = "";
    }
    String fbUserIdInClaims = "";
    if (identityProvider != null) {
        if (isFBUserIdInClaims) {
            fbUserIdInClaims = "checked=\'checked\'";
        }
    }
    if (fbAuthnEndpoint == null) {
        fbAuthnEndpoint = IdentityApplicationConstants.FB_AUTHZ_URL;
    }
    if (fbOauth2TokenEndpoint == null) {
        fbOauth2TokenEndpoint = IdentityApplicationConstants.FB_TOKEN_URL;
    }
    if (fbUserInfoEndpoint == null) {
        fbUserInfoEndpoint = IdentityApplicationConstants.FB_USER_INFO_URL;
    }


    // Out-bound Provisioning    
    String googleProvEnabledChecked = "";
    String googleProvDefaultDisabled = "";
    String googleProvDefaultChecked = "disabled=\'disabled\'";

    if (identityProvider != null) {
        if (isGoogleProvEnabled) {
            googleProvEnabledChecked = "checked=\'checked\'";
            googleProvDefaultChecked = "";
            if (isGoogleProvDefault) {
                googleProvDefaultChecked = "checked=\'checked\'";
            }
        }
    }

    if (googleDomainName == null) {
        googleDomainName = "";
    }
    if (googleUserIDClaim == null) {
        googleUserIDClaim = "";
    }
    if (googleUserIDDefaultValue == null) {
        googleUserIDDefaultValue = "";
    }
    if (googlePrimaryEmailClaim == null) {
        googlePrimaryEmailClaim = "";
    }
    if (googlePrimaryEmailDefaultValue == null) {
        googlePrimaryEmailDefaultValue = "";
    }
    if (googlePasswordClaim == null) {
        googlePasswordClaim = "";
    }
    if (googlePasswordDefaultValue == null) {
        googlePasswordDefaultValue = "";
    }
    if (googleGivenNameDefaultValue == null) {
        googleGivenNameDefaultValue = "";
    }
    if (googleFamilyNameClaim == null) {
        googleFamilyNameClaim = "";
    }
    if (googleFamilyNameDefaultValue == null) {
        googleFamilyNameDefaultValue = "";
    }
    if (googleProvServiceAccEmail == null) {
        googleProvServiceAccEmail = "";
    }
    if (googleProvAdminEmail == null) {
        googleProvAdminEmail = "";
    }
    if (googleProvApplicationName == null) {
        googleProvApplicationName = "";
    }

    if (googleProvPattern == null) {
        googleProvPattern = "";
    }

    if (googleProvisioningSeparator == null) {
        googleProvisioningSeparator = "";
    }

    String spmlProvEnabledChecked = "";
    String spmlProvDefaultDisabled = "";
    String spmlProvDefaultChecked = "disabled=\'disabled\'";


    if (identityProvider != null) {
        if (isSpmlProvEnabled) {
            spmlProvEnabledChecked = "checked=\'checked\'";
            spmlProvDefaultChecked = "";
            if (isSpmlProvDefault) {
                spmlProvDefaultChecked = "checked=\'checked\'";
            }
        }
    }

    if (spmlUserName == null) {
        spmlUserName = "";
    }
    if (spmlPassword == null) {
        spmlPassword = "";
    }
    if (spmlEndpoint == null) {
        spmlEndpoint = "";
    }
    if (spmlObjectClass == null) {
        spmlObjectClass = "";
    }

    String scimProvEnabledChecked = "";
    String scimProvDefaultDisabled = "";
    String scimProvDefaultChecked = "disabled=\'disabled\'";
    if (identityProvider != null) {
        if (isScimProvEnabled) {
            scimProvEnabledChecked = "checked=\'checked\'";
            scimProvDefaultChecked = "";
            if (isScimProvDefault) {
                scimProvDefaultChecked = "checked=\'checked\'";
            }
        }
    }

    if (scimUserName == null) {
        scimUserName = "";
    }
    if (scimPassword == null) {
        scimPassword = "";
    }
    if (scimGroupEp == null) {
        scimGroupEp = "";
    }
    if (scimUserEp == null) {
        scimUserEp = "";
    }
    if (scimUserStoreDomain == null) {
        scimUserStoreDomain = "";
    }

    String sfProvEnabledChecked = "";
    String sfProvDefaultDisabled = "";
    String sfProvDefaultChecked = "disabled=\'disabled\'";

    if (identityProvider != null) {
        if (isSfProvEnabled) {
            sfProvEnabledChecked = "checked=\'checked\'";
            sfProvDefaultChecked = "";
            if (isSfProvDefault) {
                sfProvDefaultChecked = "checked=\'checked\'";
            }
        }
    }

    if (sfApiVersion == null) {
        sfApiVersion = "";
    }
    if (sfDomainName == null) {
        sfDomainName = "";
    }
    if (sfClientId == null) {
        sfClientId = "";
    }
    if (sfClientSecret == null) {
        sfClientSecret = "";
    }
    if (sfUserName == null) {
        sfUserName = "";
    }
    if (sfPassword == null) {
        sfPassword = "";
    }
    if (sfOauth2TokenEndpoint == null) {
        sfOauth2TokenEndpoint = IdentityApplicationConstants.SF_OAUTH2_TOKEN_ENDPOINT;
    }
    if (sfProvPattern == null) {
        sfProvPattern = "";
    }

    if (sfProvSeparator == null) {
        sfProvSeparator = "";
    }

    if (sfProvDomainName == null) {
        sfProvDomainName = "";
    }
%>

<script>

var claimMappinRowID = -1;
var claimMappinRowIDSPML = -1;
var advancedClaimMappinRowID = -1;
var roleRowId = -1;
var claimRowId = -1;

<% if(identityProviderClaims != null){ %>
claimRowId = <%=identityProviderClaims.length-1%>;
<% } %>

<% if(roles != null){ %>
roleRowId = <%=roles.length-1%>;
<% } %>

<% if(claimMappings != null){ %>
advancedClaimMappinRowID = <%=claimMappings.length-1%>;
<% } %>


var claimURIDropdownPopulator = function () {
    var $user_id_claim_dropdown = jQuery('#user_id_claim_dropdown');
    var $role_claim_dropdown = jQuery('#role_claim_dropdown');
    var $google_prov_email_claim_dropdown = jQuery('#google_prov_email_claim_dropdown');
    var $google_prov_familyname_claim_dropdown = jQuery('#google_prov_familyname_claim_dropdown');
    var $google_prov_givenname_claim_dropdown = jQuery('#google_prov_givenname_claim_dropdown');
    var $idpClaimsList2 = jQuery('#idpClaimsList2');


    $user_id_claim_dropdown.empty();
    $role_claim_dropdown.empty();
    $google_prov_email_claim_dropdown.empty();
    $google_prov_familyname_claim_dropdown.empty();
    $google_prov_givenname_claim_dropdown.empty();
    $idpClaimsList2.empty();


    if ('<%=userIdClaimURI%>' == '') {
        $user_id_claim_dropdown.append('<option value = "">--- Select Claim URI ---</option>');
    } else {
        $user_id_claim_dropdown.append('<option selected="selected" value = "">--- Select Claim URI ---</option>');
    }

    if ('<%=roleClaimURI%>' == '') {
        $role_claim_dropdown.append('<option value = "">--- Select Claim URI ---</option>');
    } else {
        $role_claim_dropdown.append('<option selected="selected" value = "">--- Select Claim URI ---</option>');
    }


    if ('<%=googlePrimaryEmailClaim%>' == '') {
        $google_prov_email_claim_dropdown.append('<option value = "">--- Select Claim URI ---</option>');
    } else {
        $google_prov_email_claim_dropdown.append('<option selected="selected" value = "">--- Select Claim URI ---</option>');
    }

    if ('<%=googleFamilyNameClaim%>' == '') {
        $google_prov_familyname_claim_dropdown.append('<option value = "">--- Select Claim URI ---</option>');
    } else {
        $google_prov_familyname_claim_dropdown.append('<option selected="selected" value = "">--- Select Claim URI ---</option>');
    }

    if ('<%=googleGivenNameClaim%>' == '') {
        $google_prov_givenname_claim_dropdown.append('<option value = "">--- Select Claim URI ---</option>');
    } else {
        $google_prov_givenname_claim_dropdown.append('<option selected="selected" value = "">--- Select Claim URI ---</option>');
    }

    $idpClaimsList2.append('<option value = "" >--- Select Claim URI ---</option>');

    jQuery('#claimAddTable .claimrow').each(function () {
        if ($(this).val().trim() != "") {
            var val = $(this).val();
            if (val == '<%=userIdClaimURI%>') {
                $user_id_claim_dropdown.append('<option selected="selected">' + val + '</option>');
            } else {
                $user_id_claim_dropdown.append('<option>' + val + '</option>');
            }
            if (val == '<%=roleClaimURI%>') {
                $role_claim_dropdown.append('<option selected="selected">' + val + '</option>');
            } else {
                $role_claim_dropdown.append('<option>' + val + '</option>');
            }

            if (val == '<%=googlePrimaryEmailClaim%>') {
                $google_prov_email_claim_dropdown.append('<option selected="selected">' + val + '</option>');
            } else {
                $google_prov_email_claim_dropdown.append('<option>' + val + '</option>');
            }

            if (val == '<%=googleFamilyNameClaim%>') {
                $google_prov_familyname_claim_dropdown.append('<option selected="selected">' + val + '</option>');
            } else {
                $google_prov_familyname_claim_dropdown.append('<option>' + val + '</option>');
            }

            if (val == '<%=googleGivenNameClaim%>') {
                $google_prov_givenname_claim_dropdown.append('<option selected="selected">' + val + '</option>');
            } else {
                $google_prov_givenname_claim_dropdown.append('<option>' + val + '</option>');
            }

            $idpClaimsList2.append('<option>' + val + '</option>');

        }
    })

    var selectedVal = "";
    var selected = $("input[type='radio'][name='choose_dialet_type_group']:checked");
    if (selected.length > 0) {
        selectedVal = selected.val();
    }

    if (selectedVal == "choose_dialet_type1") {
        $(".customClaim").hide();
        var option = '<option value="">---Select Claim URI ---</option>';
        $user_id_claim_dropdown.empty();
        $role_claim_dropdown.empty();
        $google_prov_email_claim_dropdown.empty();
        $google_prov_familyname_claim_dropdown.empty();
        $google_prov_givenname_claim_dropdown.empty();
        $idpClaimsList2.empty();


        var user_id_option = '<option value="">---Select Claim URI ---</option>';

        <% for(int i =0 ; i< claimUris.length ; i++){

           		 if(claimUris[i].equals(userIdClaimURI)){  %>
        user_id_option += '<option  selected="selected" value="' + "<%=claimUris[i]%>" + '">' + "<%=claimUris[i]%>" + '</option>';
        <% 	 } else {  %>
        user_id_option += '<option value="' + "<%=claimUris[i]%>" + '">' + "<%=claimUris[i]%>" + '</option>';
        <%	 }
            }%>


        var google_prov_email_option = '<option value="">---Select Claim URI ---</option>';

        <% for(int i =0 ; i< claimUris.length ; i++){

           		 if(claimUris[i].equals(googlePrimaryEmailClaim)){  %>
        google_prov_email_option += '<option  selected="selected" value="' + "<%=claimUris[i]%>" + '">' + "<%=claimUris[i]%>" + '</option>';
        <% 	 } else {  %>
        google_prov_email_option += '<option value="' + "<%=claimUris[i]%>" + '">' + "<%=claimUris[i]%>" + '</option>';
        <%	 }
            }%>


        var google_prov_family_email_option = '<option value="">---Select Claim URI ---</option>';

        <% for(int i =0 ; i< claimUris.length ; i++){

           		 if(claimUris[i].equals(googleFamilyNameClaim)){  %>
        google_prov_family_email_option += '<option  selected="selected" value="' + "<%=claimUris[i]%>" + '">' + "<%=claimUris[i]%>" + '</option>';
        <% 	 } else {  %>
        google_prov_family_email_option += '<option value="' + "<%=claimUris[i]%>" + '">' + "<%=claimUris[i]%>" + '</option>';
        <%	 }
            }%>


        var google_prov_givenname_option = '<option value="">---Select Claim URI ---</option>';

        <% for(int i =0 ; i< claimUris.length ; i++){

           		 if(claimUris[i].equals(googleGivenNameClaim)){  %>
        google_prov_givenname_option += '<option  selected="selected" value="' + "<%=claimUris[i]%>" + '">' + "<%=claimUris[i]%>" + '</option>';
        <% 	 } else {  %>
        google_prov_givenname_option += '<option value="' + "<%=claimUris[i]%>" + '">' + "<%=claimUris[i]%>" + '</option>';
        <%	 }
            }%>


        <% for(int i =0 ; i< claimUris.length ; i++){%>
        option += '<option value="' + "<%=claimUris[i]%>" + '">' + "<%=claimUris[i]%>" + '</option>';

        <%}%>


        $user_id_claim_dropdown.append(user_id_option);
        $role_claim_dropdown.append('<option value="http://wso2.org/claims/role">http://wso2.org/claims/role</option>');
        $google_prov_email_claim_dropdown.append(google_prov_email_option);
        $google_prov_familyname_claim_dropdown.append(google_prov_family_email_option);
        $google_prov_givenname_claim_dropdown.append(google_prov_givenname_option);
        $idpClaimsList2.append(option);


        $(".role_claim").hide();
        $(jQuery('#claimAddTable')).hide();

        if ($(jQuery('#advancedClaimMappingAddTable tr')).length > 1) {
            $(jQuery('#advancedClaimMappingAddTable')).show();
        }
    }

    if (selectedVal == "choose_dialet_type2") {
        var option = '';

        <% for(int i =0 ; i< claimUris.length ; i++){%>
        option += '<option value="' + "<%=claimUris[i]%>" + '">' + "<%=claimUris[i]%>" + '</option>';

        <%}%>

        $user_id_claim_dropdown.replace($option, "");
        $role_claim_dropdown.replace('<option value="http://wso2.org/claims/role">http://wso2.org/claims/role</option>', "");
        $google_prov_email_claim_dropdown.replace($option, "");
        $google_prov_familyname_claim_dropdown.replace($option, "");
        $google_prov_givenname_claim_dropdown.replace($option, "");
        $idpClaimsList2.replace($option, "");


        $(".role_claim").show();

        if ($(jQuery('#claimAddTable tr')).length == 2) {
            $(jQuery('#claimAddTable')).toggle();
        }

        if ($(jQuery('#advancedClaimMappingAddTable tr')).length > 1) {
            $(jQuery('#advancedClaimMappingAddTable')).show();
        }

    }
};

function deleteRow(obj) {
    jQuery(obj).parent().parent().remove();

}


jQuery(document).ready(function () {
    jQuery('#outBoundAuth').hide();
    jQuery('#inBoundProvisioning').hide();
    jQuery('#outBoundProvisioning').hide();
    jQuery('#roleConfig').hide();
    jQuery('#claimConfig').hide();
    jQuery('#openIdLinkRow').hide();
    jQuery('#saml2SSOLinkRow').hide();
    jQuery('#oauth2LinkRow').hide();
    jQuery('#passiveSTSLinkRow').hide();
    jQuery('#fbAuthLinkRow').hide();
    jQuery('#baisClaimLinkRow').hide();
    jQuery('#advancedClaimLinkRow').hide();
    jQuery('#openIdDefault').attr('disabled', 'disabled');
    jQuery('#saml2SSODefault').attr('disabled', 'disabled');
    jQuery('#oidcDefault').attr('disabled', 'disabled');
    jQuery('#passiveSTSDefault').attr('disabled', 'disabled');
    jQuery('#fbAuthDefault').attr('disabled', 'disabled');
    jQuery('#googleProvDefault').attr('disabled', 'disabled');
    jQuery('#sfProvDefault').attr('disabled', 'disabled');
    jQuery('#scimProvDefault').attr('disabled', 'disabled');
    jQuery('#spmlProvDefault').attr('disabled', 'disabled');
    jQuery('#openIdDefault').attr('disabled', 'disabled');
    jQuery('#saml2SSODefault').attr('disabled', 'disabled');
    jQuery('#oidcDefault').attr('disabled', 'disabled');
    jQuery('#passiveSTSDefault').attr('disabled', 'disabled');
    jQuery('#fbAuthDefault').attr('disabled', 'disabled');

    if ($(jQuery('#claimMappingAddTable tr')).length < 2) {
        $(jQuery('#claimMappingAddTable')).hide();
    }

    if ($(jQuery('#claimMappingAddTableSPML tr')).length < 2) {
        $(jQuery('#claimMappingAddTableSPML')).hide();
    }


    if (<%=isOpenIdEnabled%>) {
        jQuery('#openid_enable_logo').show();
    } else {
        jQuery('#openid_enable_logo').hide();
    }

    if (<%=isSAML2SSOEnabled%>) {
        jQuery('#sampl2sso_enable_logo').show();
    } else {
        jQuery('#sampl2sso_enable_logo').hide();
    }

    if (<%=isOIDCEnabled%>) {
        jQuery('#oAuth2_enable_logo').show();
    } else {
        jQuery('#oAuth2_enable_logo').hide();
    }

    if (<%=isPassiveSTSEnabled%>) {
        jQuery('#wsfederation_enable_logo').show();
    } else {
        jQuery('#wsfederation_enable_logo').hide();
    }

    if (<%=isFBAuthEnabled%>) {
        jQuery('#fecebook_enable_logo').show();
    } else {
        jQuery('#fecebook_enable_logo').hide();
    }

    if (<%=isGoogleProvEnabled%>) {
        jQuery('#google_enable_logo').show();
    } else {
        jQuery('#google_enable_logo').hide();
    }

    if (<%=isSfProvEnabled%>) {
        jQuery('#sf_enable_logo').show();
    } else {
        jQuery('#sf_enable_logo').hide();
    }

    if (<%=isScimProvEnabled%>) {
        jQuery('#scim_enable_logo').show();
    } else {
        jQuery('#scim_enable_logo').hide();
    }

    if (<%=isSpmlProvEnabled%>) {
        jQuery('#spml_enable_logo').show();
    } else {
        jQuery('#spml_enable_logo').hide();
    }

    jQuery('h2.trigger').click(function () {
        if (jQuery(this).next().is(":visible")) {
            this.className = "active trigger";
        } else {
            this.className = "trigger";
        }
        jQuery(this).next().slideToggle("fast");
        return false; //Prevent the browser jump to the link anchor
    })
    jQuery('#publicCertDeleteLink').click(function () {
        $(jQuery('#publicCertDiv')).toggle();
        var input = document.createElement('input');
        input.type = "hidden";
        input.name = "deletePublicCert";
        input.id = "deletePublicCert";
        input.value = "true";
        document.forms['idp-mgt-edit-form'].appendChild(input);
    })
    jQuery('#claimAddLink').click(function () {

        claimRowId++;
        var option = '<option value="">---Select Claim URI ---</option>';

        <% for(int i =0 ; i< claimUris.length ; i++){%>
        option += '<option value="' + "<%=claimUris[i]%>" + '">' + "<%=claimUris[i]%>" + '</option>';

        <%}%>

        $("#claimrow_id_count").val(claimRowId + 1);


        var newrow = jQuery('<tr><td><input class="claimrow" style=" width: 90%; " type="text" id="claimrowid_' + claimRowId + '" name="claimrowname_' + claimRowId + '"/></td>' +
                '<td><select class="claimrow_wso2" name="claimrow_name_wso2_' + claimRowId + '">' + option + '</select></td> ' +
                '<td><a onclick="deleteClaimRow(this)" class="icon-link" ' +
                'style="background-image: url(images/delete.gif)">' +
                'Delete' +
                '</a></td></tr>');
        jQuery('.claimrow', newrow).blur(function () {
            claimURIDropdownPopulator();
        });
        jQuery('#claimAddTable').append(newrow);
        if ($(jQuery('#claimAddTable tr')).length == 2) {
            $(jQuery('#claimAddTable')).toggle();
        }

    })
    jQuery('#claimAddTable .claimrow').blur(function () {
        claimURIDropdownPopulator();
    });
    jQuery('#claimMappingDeleteLink').click(function () {
        $(jQuery('#claimMappingDiv')).toggle();
        var input = document.createElement('input');
        input.type = "hidden";
        input.name = "deleteClaimMappings";
        input.id = "deleteClaimMappings";
        input.value = "true";
        document.forms['idp-mgt-edit-form'].appendChild(input);
    });
    jQuery('#roleAddLink').click(function () {
        roleRowId++;
        $("#rolemappingrow_id_count").val(roleRowId + 1);
        jQuery('#roleAddTable').append(jQuery('<tr><td><input type="text" id="rolerowname_' + roleRowId + '" name="rolerowname_' + roleRowId + '"/></td>' +
                '<td><input type="text" id="localrowname_' + roleRowId + '" name="localrowname_' + roleRowId + '"/></td>' +
                '<td><a onclick="deleteRoleRow(this)" class="icon-link" ' +
                'style="background-image: url(images/delete.gif)">' +
                'Delete' +
                '</a></td></tr>'));
        if ($(jQuery('#roleAddTable tr')).length == 2) {
            $(jQuery('#roleAddTable')).toggle();
        }
    });


    jQuery('#roleMappingDeleteLink').click(function () {
        $(jQuery('#roleMappingDiv')).toggle();
        var input = document.createElement('input');
        input.type = "hidden";
        input.name = "deleteRoleMappings";
        input.id = "deleteRoleMappings";
        input.value = "true";
        document.forms['idp-mgt-edit-form'].appendChild(input);
    });
    jQuery('#provision_disabled').click(function () {
        jQuery('#provision_static_dropdown').attr('disabled', 'disabled');
    });
    jQuery('#provision_static').click(function () {
        jQuery('#provision_static_dropdown').removeAttr('disabled');
    });


    jQuery('#advancedClaimMappingAddLink').click(function () {
        var selectedIDPClaimName = $('select[name=idpClaimsList2]').val();
        if (selectedIDPClaimName == "" || selectedIDPClaimName == null) {
            CARBON.showWarningDialog('Add valid attribute');
            return false;
        }
        advancedClaimMappinRowID++;
        $("#advanced_claim_id_count").val(advancedClaimMappinRowID + 1);
        jQuery('#advancedClaimMappingAddTable').append(jQuery('<tr>' +
                '<td><input type="text" style="width: 99%;" value="' + selectedIDPClaimName + '" id="advancnedIdpClaim_' + advancedClaimMappinRowID + '" name="advancnedIdpClaim_' + advancedClaimMappinRowID + '" readonly="readonly" /></td>' +
                '<td><input type="text" style="width: 99%;" id="advancedDefault_' + advancedClaimMappinRowID + '" name="advancedDefault_' + advancedClaimMappinRowID + '"/></td> ' +
                '<td><a onclick="deleteRow(this);return false;" href="#" class="icon-link" style="background-image: url(images/delete.gif)"> Delete</a></td>' +

                '</tr>'));

        $(jQuery('#advancedClaimMappingAddTable')).show();

    });


    jQuery('#choose_dialet_type1').click(function () {
        $(".customClaim").hide();
        $(".role_claim").hide();
        deleteRows();
        claimURIDropdownPopulator();
        $("#advancedClaimMappingAddTable tbody > tr").remove();
        $('#advancedClaimMappingAddTable').hide();

    });

    jQuery('#choose_dialet_type2').click(function () {
        $(".customClaim").show();
        $(".role_claim").show();
        $("#advancedClaimMappingAddTable tbody > tr").remove();
        $('#advancedClaimMappingAddTable').hide();
        claimURIDropdownPopulator();
    });

    claimURIDropdownPopulator();
})
var deleteClaimRows = [];
function deleteClaimRow(obj) {
    if (jQuery(obj).parent().prev().children()[0].value != '') {
        deleteClaimRows.push(jQuery(obj).parent().prev().children()[0].value);
    }
    jQuery(obj).parent().parent().remove();
    if ($(jQuery('#claimAddTable tr')).length == 1) {
        $(jQuery('#claimAddTable')).toggle();
    }
    claimURIDropdownPopulator();
}
var deletedRoleRows = [];
function deleteRoleRow(obj) {
    if (jQuery(obj).parent().prev().children()[0].value != '') {
        deletedRoleRows.push(jQuery(obj).parent().prev().children()[0].value);
    }
    jQuery(obj).parent().parent().remove();

}


function deleteRows() {
    $.each($('.claimrow'), function () {
        $(this).parent().parent().remove();
    });
}

function checkEnabledLogo(obj, name) {
    if (jQuery(obj).attr('checked')) {
        jQuery('#custom_auth_head_enable_logo_' + name).show();
    } else {
        jQuery('#custom_auth_head_enable_logo_' + name).hide();
    }

}

function getEnabledCustomAuth() {
    var textMap = {};

    jQuery("input[name$='_Enabled']").each(function () {
        textMap[this.id] = $(this).text();
    });

    return textMap;
}

function isCustomAuthEnabled() {
    var enable = false;
    for (id in getEnabledCustomAuth()) {
        if (jQuery('#' + id).attr('checked')) {
            enable = true;
        }
    }
    return enable;
}


function isOtherCustomAuthEnabled(selectedId) {
    var enable = false;
    for (id in getEnabledCustomAuth()) {
        if (id == selectedId) {
            //other than selected 
        } else {
            if (jQuery('#' + id).attr('checked')) {
                enable = true;
            }
        }
    }
    return enable;
}

function checkEnabled(obj) {

    if (jQuery(obj).attr('checked')) {
        if (jQuery(obj).attr('id') == 'openIdEnabled') {
            if (!jQuery('#saml2SSOEnabled').attr('checked') && !jQuery('#oidcEnabled').attr('checked') && !jQuery('#passiveSTSEnabled').attr('checked') && !jQuery('#fbAuthEnabled').attr('checked') && !isCustomAuthEnabled()) {
                jQuery('#openIdDefault').attr('checked', 'checked');
                jQuery('#openIdDefault').attr('disabled', 'disabled');


            } else {
                jQuery('#openIdDefault').removeAttr('disabled');
            }

            jQuery('#openid_enable_logo').show();
        } else if (jQuery(obj).attr('id') == 'saml2SSOEnabled') {
            if (!jQuery('#openIdEnabled').attr('checked') && !jQuery('#oidcEnabled').attr('checked') && !jQuery('#passiveSTSEnabled').attr('checked') && !jQuery('#fbAuthEnabled').attr('checked') && !isCustomAuthEnabled()) {
                jQuery('#saml2SSODefault').attr('checked', 'checked');
                jQuery('#saml2SSODefault').attr('disabled', 'disabled');
            } else {
                jQuery('#saml2SSODefault').removeAttr('disabled');
            }
            jQuery('#sampl2sso_enable_logo').show();
        } else if (jQuery(obj).attr('id') == 'oidcEnabled') {
            if (!jQuery('#openIdEnabled').attr('checked') && !jQuery('#saml2SSOEnabled').attr('checked') && !jQuery('#passiveSTSEnabled').attr('checked') && !jQuery('#fbAuthEnabled').attr('checked') && !isCustomAuthEnabled()) {
                jQuery('#oidcDefault').attr('checked', 'checked');
                jQuery('#oidcDefault').attr('disabled', 'disabled');
            } else {
                jQuery('#oidcDefault').removeAttr('disabled');
            }
            jQuery('#oAuth2_enable_logo').show();
        } else if (jQuery(obj).attr('id') == 'passiveSTSEnabled') {
            if (!jQuery('#saml2SSOEnabled').attr('checked') && !jQuery('#oidcEnabled').attr('checked') && !jQuery('#openIdEnabled').attr('checked') && !jQuery('#fbAuthEnabled').attr('checked') && !isCustomAuthEnabled()) {
                jQuery('#passiveSTSDefault').attr('checked', 'checked');
                jQuery('#passiveSTSDefault').attr('disabled', 'disabled');
            } else {
                jQuery('#passiveSTSDefault').removeAttr('disabled');
            }
            jQuery('#wsfederation_enable_logo').show();
        } else if (jQuery(obj).attr('id') == 'fbAuthEnabled') {
            if (!jQuery('#saml2SSOEnabled').attr('checked') && !jQuery('#oidcEnabled').attr('checked') && !jQuery('#passiveSTSEnabled').attr('checked') && !jQuery('#openIdEnabled').attr('checked') && !isCustomAuthEnabled()) {
                jQuery('#fbAuthDefault').attr('checked', 'checked');
                jQuery('#fbAuthDefault').attr('disabled', 'disabled');
            } else {
                jQuery('#fbAuthDefault').removeAttr('disabled');
            }
            jQuery('#fecebook_enable_logo').show();
        } else {
            for (id in getEnabledCustomAuth()) {
                if (jQuery(obj).attr('id') == id) {
                    var defId = '#' + id.replace("_Enabled", "_Default");
                    if (!jQuery('#saml2SSOEnabled').attr('checked') && !jQuery('#oidcEnabled').attr('checked') && !jQuery('#passiveSTSEnabled').attr('checked') && !jQuery('#openIdEnabled').attr('checked') && !jQuery('#fbAuthEnabled').attr('checked') && !isOtherCustomAuthEnabled(id)) {
                        jQuery(defId).attr('checked', 'checked');
                        jQuery(defId).attr('disabled', 'disabled');
                    } else {
                        jQuery(defId).removeAttr('disabled');
                    }
                }
            }
        }
    } else {
        if (jQuery(obj).attr('id') == 'openIdEnabled') {
            if (jQuery('#saml2SSOEnabled').attr('checked') ||
                    jQuery('#passiveSTSEnabled').attr('checked') ||
                    jQuery('#oidcEnabled').attr('checked') ||
                    jQuery('#fbAuthEnabled').attr('checked') || isCustomAuthEnabled()) {

                if (jQuery('#openIdDefault').attr('checked')) {
                    jQuery('#openIdEnabled').attr('checked', 'checked');
                    CARBON.showWarningDialog("Make other enabled authenticator to default before disabling default authenticator");
                } else {
                    jQuery('#openIdDefault').attr('disabled', 'disabled');
                    jQuery('#openIdDefault').removeAttr('checked');
                    jQuery('#openid_enable_logo').hide();
                }
            } else {
                jQuery('#openIdDefault').attr('disabled', 'disabled');
                jQuery('#openIdDefault').removeAttr('checked');
                jQuery('#openid_enable_logo').hide();
            }


        } else if (jQuery(obj).attr('id') == 'saml2SSOEnabled') {

            if (jQuery('#openIdEnabled').attr('checked') ||
                    jQuery('#passiveSTSEnabled').attr('checked') ||
                    jQuery('#oidcEnabled').attr('checked') ||
                    jQuery('#fbAuthEnabled').attr('checked') || isCustomAuthEnabled()) {

                if (jQuery('#saml2SSODefault').attr('checked')) {
                    jQuery('#saml2SSOEnabled').attr('checked', 'checked');
                    CARBON.showWarningDialog("Make other enabled authenticator to default before disabling default authenticator");
                } else {
                    jQuery('#saml2SSODefault').attr('disabled', 'disabled');
                    jQuery('#saml2SSODefault').removeAttr('checked');
                    jQuery('#sampl2sso_enable_logo').hide();
                }
            } else {
                jQuery('#saml2SSODefault').attr('disabled', 'disabled');
                jQuery('#saml2SSODefault').removeAttr('checked');
                jQuery('#sampl2sso_enable_logo').hide();
            }

        } else if (jQuery(obj).attr('id') == 'oidcEnabled') {

            if (jQuery('#saml2SSOEnabled').attr('checked') ||
                    jQuery('#passiveSTSEnabled').attr('checked') ||
                    jQuery('#openIdEnabled').attr('checked') ||
                    jQuery('#fbAuthEnabled').attr('checked') || isCustomAuthEnabled()) {

                if (jQuery('#oidcDefault').attr('checked')) {
                    jQuery('#oidcEnabled').attr('checked', 'checked');
                    CARBON.showWarningDialog("Make other enabled authenticator to default before disabling default authenticator");
                } else {
                    jQuery('#oidcDefault').attr('disabled', 'disabled');
                    jQuery('#oidcDefault').removeAttr('checked');
                    jQuery('#oAuth2_enable_logo').hide();
                }
            } else {
                jQuery('#oidcDefault').attr('disabled', 'disabled');
                jQuery('#oidcDefault').removeAttr('checked');
                jQuery('#oAuth2_enable_logo').hide();
            }
        } else if (jQuery(obj).attr('id') == 'passiveSTSEnabled') {

            if (jQuery('#saml2SSOEnabled').attr('checked') ||
                    jQuery('#oidcEnabled').attr('checked') ||
                    jQuery('#openIdEnabled').attr('checked') ||
                    jQuery('#fbAuthEnabled').attr('checked') || isCustomAuthEnabled()) {

                if (jQuery('#passiveSTSDefault').attr('checked')) {
                    jQuery('#passiveSTSEnabled').attr('checked', 'checked');
                    CARBON.showWarningDialog("Make other enabled authenticator to default before disabling default authenticator");
                } else {
                    jQuery('#passiveSTSDefault').attr('disabled', 'disabled');
                    jQuery('#passiveSTSDefault').removeAttr('checked');
                    jQuery('#wsfederation_enable_logo').hide();
                }
            } else {
                jQuery('#passiveSTSDefault').attr('disabled', 'disabled');
                jQuery('#passiveSTSDefault').removeAttr('checked');
                jQuery('#wsfederation_enable_logo').hide();
            }

        } else if (jQuery(obj).attr('id') == 'fbAuthEnabled') {

            if (jQuery('#saml2SSOEnabled').attr('checked') ||
                    jQuery('#oidcEnabled').attr('checked') ||
                    jQuery('#openIdEnabled').attr('checked') ||
                    jQuery('#passiveSTSEnabled').attr('checked') || isCustomAuthEnabled()) {

                if (jQuery('#fbAuthDefault').attr('checked')) {
                    jQuery('#fbAuthEnabled').attr('checked', 'checked');
                    CARBON.showWarningDialog("Make other enabled authenticator to default before disabling default authenticator");
                } else {
                    jQuery('#fbAuthDefault').attr('disabled', 'disabled');
                    jQuery('#fbAuthDefault').removeAttr('checked');
                    jQuery('#fecebook_enable_logo').hide();
                }
            } else {
                jQuery('#fbAuthDefault').attr('disabled', 'disabled');
                jQuery('#fbAuthDefault').removeAttr('checked');
                jQuery('#fecebook_enable_logo').hide();
            }
        } else {
            for (id in getEnabledCustomAuth()) {
                if (jQuery(obj).attr('id') == id) {
                    var defId = '#' + id.replace("_Enabled", "_Default");
                    if (jQuery('#saml2SSOEnabled').attr('checked') ||
                            jQuery('#oidcEnabled').attr('checked') ||
                            jQuery('#passiveSTSEnabled').attr('checked') ||
                            jQuery('#openIdEnabled').attr('checked') ||
                            jQuery('#fbAuthEnabled').attr('checked') || isOtherCustomAuthEnabled(id)) {

                        if (jQuery(defId).attr('checked')) {
                            jQuery('#' + id).attr('checked', 'checked');
                            CARBON.showWarningDialog("Make other enabled authenticator to default before disabling default authenticator");
                        } else {
                            jQuery(defId).attr('disabled', 'disabled');
                            jQuery(defId).removeAttr('checked');
                        }
                    } else {
                        jQuery(defId).attr('disabled', 'disabled');
                        jQuery(defId).removeAttr('checked');
                    }
                }
            }
        }
    }
}

function checkDefault(obj) {
    if (jQuery(obj).attr('id') == 'openIdDefault') {
        jQuery('#saml2SSODefault').removeAttr('checked');
        jQuery('#oidcDefault').removeAttr('checked');
        jQuery('#passiveSTSDefault').removeAttr('checked');
        jQuery('#fbAuthDefault').removeAttr('checked');
        if (jQuery('#saml2SSOEnabled').attr('checked')) {
            jQuery('#saml2SSODefault').removeAttr('disabled');
        }
        if (jQuery('#oidcEnabled').attr('checked')) {
            jQuery('#oidcDefault').removeAttr('disabled');
        }
        if (jQuery('#passiveSTSEnabled').attr('checked')) {
            jQuery('#passiveSTSDefault').removeAttr('disabled');
        }
        if (jQuery('#fbAuthEnabled').attr('checked')) {
            jQuery('#fbAuthDefault').removeAttr('disabled');
        }

        for (id in getEnabledCustomAuth()) {
            var defId = '#' + id.replace("_Enabled", "_Default");
            jQuery(defId).removeAttr('checked');

            if (jQuery('#' + id).attr('checked')) {
                jQuery(defId).removeAttr('disabled');
            }
        }
        jQuery('#openIdDefault').attr('disabled', 'disabled');
    } else if (jQuery(obj).attr('id') == 'saml2SSODefault') {
        jQuery('#openIdDefault').removeAttr('checked');
        jQuery('#oidcDefault').removeAttr('checked');
        jQuery('#passiveSTSDefault').removeAttr('checked');
        jQuery('#fbAuthDefault').removeAttr('checked');
        if (jQuery('#openIdEnabled').attr('checked')) {
            jQuery('#openIdDefault').removeAttr('disabled');
        }
        if (jQuery('#oidcEnabled').attr('checked')) {
            jQuery('#oidcDefault').removeAttr('disabled');
        }
        if (jQuery('#passiveSTSEnabled').attr('checked')) {
            jQuery('#passiveSTSDefault').removeAttr('disabled');
        }
        if (jQuery('#fbAuthEnabled').attr('checked')) {
            jQuery('#fbAuthDefault').removeAttr('disabled');
        }
        for (id in getEnabledCustomAuth()) {
            var defId = '#' + id.replace("_Enabled", "_Default");
            jQuery(defId).removeAttr('checked');

            if (jQuery('#' + id).attr('checked')) {
                jQuery(defId).removeAttr('disabled');
            }
        }
        jQuery('#saml2SSODefault').attr('disabled', 'disabled');
    } else if (jQuery(obj).attr('id') == 'oidcDefault') {
        jQuery('#openIdDefault').removeAttr('checked');
        jQuery('#saml2SSODefault').removeAttr('checked');
        jQuery('#passiveSTSDefault').removeAttr('checked');
        jQuery('#fbAuthDefault').removeAttr('checked');
        if (jQuery('#openIdEnabled').attr('checked')) {
            jQuery('#openIdDefault').removeAttr('disabled');
        }
        if (jQuery('#saml2SSOEnabled').attr('checked')) {
            jQuery('#saml2SSODefault').removeAttr('disabled');
        }
        if (jQuery('#passiveSTSEnabled').attr('checked')) {
            jQuery('#passiveSTSDefault').removeAttr('disabled');
        }
        if (jQuery('#fbAuthEnabled').attr('checked')) {
            jQuery('#fbAuthDefault').removeAttr('disabled');
        }
        for (id in getEnabledCustomAuth()) {
            var defId = '#' + id.replace("_Enabled", "_Default");
            jQuery(defId).removeAttr('checked');

            if (jQuery('#' + id).attr('checked')) {
                jQuery(defId).removeAttr('disabled');
            }
        }
        jQuery('#oidcDefault').attr('disabled', 'disabled');
    } else if (jQuery(obj).attr('id') == 'passiveSTSDefault') {
        jQuery('#openIdDefault').removeAttr('checked');
        jQuery('#saml2SSODefault').removeAttr('checked');
        jQuery('#oidcDefault').removeAttr('checked');
        jQuery('#fbAuthDefault').removeAttr('checked');
        if (jQuery('#openIdEnabled').attr('checked')) {
            jQuery('#openIdDefault').removeAttr('disabled');
        }
        if (jQuery('#saml2SSOEnabled').attr('checked')) {
            jQuery('#saml2SSODefault').removeAttr('disabled');
        }
        if (jQuery('#oidcEnabled').attr('checked')) {
            jQuery('#oidcDefault').removeAttr('disabled');
        }
        if (jQuery('#fbAuthEnabled').attr('checked')) {
            jQuery('#fbAuthDefault').removeAttr('disabled');
        }
        for (id in getEnabledCustomAuth()) {
            var defId = '#' + id.replace("_Enabled", "_Default");
            jQuery(defId).removeAttr('checked');

            if (jQuery('#' + id).attr('checked')) {
                jQuery(defId).removeAttr('disabled');
            }
        }
        jQuery('#passiveSTSDefault').attr('disabled', 'disabled');
    } else if (jQuery(obj).attr('id') == 'fbAuthDefault') {
        jQuery('#openIdDefault').removeAttr('checked');
        jQuery('#saml2SSODefault').removeAttr('checked');
        jQuery('#oidcDefault').removeAttr('checked');
        jQuery('#passiveSTSDefault').removeAttr('checked');
        if (jQuery('#openIdEnabled').attr('checked')) {
            jQuery('#openIdDefault').removeAttr('disabled');
        }
        if (jQuery('#saml2SSOEnabled').attr('checked')) {
            jQuery('#saml2SSODefault').removeAttr('disabled');
        }
        if (jQuery('#oidcEnabled').attr('checked')) {
            jQuery('#oidcDefault').removeAttr('disabled');
        }
        if (jQuery('#passiveSTSEnabled').attr('checked')) {
            jQuery('#passiveSTSDefault').removeAttr('disabled');
        }
        for (id in getEnabledCustomAuth()) {
            var defId = '#' + id.replace("_Enabled", "_Default");
            jQuery(defId).removeAttr('checked');

            if (jQuery('#' + id).attr('checked')) {
                jQuery(defId).removeAttr('disabled');
            }
        }
        jQuery('#fbAuthDefault').attr('disabled', 'disabled');
    } else {
        for (id in getEnabledCustomAuth()) {
            var defId = id.replace("_Enabled", "_Default");
            if (jQuery(obj).attr('id') == defId) {
                jQuery('#openIdDefault').removeAttr('checked');
                jQuery('#saml2SSODefault').removeAttr('checked');
                jQuery('#oidcDefault').removeAttr('checked');
                jQuery('#passiveSTSDefault').removeAttr('checked');
                jQuery('#fbAuthDefault').removeAttr('checked');

                if (jQuery('#openIdEnabled').attr('checked')) {
                    jQuery('#openIdDefault').removeAttr('disabled');
                }
                if (jQuery('#saml2SSOEnabled').attr('checked')) {
                    jQuery('#saml2SSODefault').removeAttr('disabled');
                }
                if (jQuery('#oidcEnabled').attr('checked')) {
                    jQuery('#oidcDefault').removeAttr('disabled');
                }
                if (jQuery('#passiveSTSEnabled').attr('checked')) {
                    jQuery('#passiveSTSDefault').removeAttr('disabled');
                }
                if (jQuery('#fbAuthEnabled').attr('checked')) {
                    jQuery('#fbAuthDefault').removeAttr('disabled');
                }

                for (idE in getEnabledCustomAuth()) {
                    var defIdE = idE.replace("_Enabled", "_Default");

                    if (jQuery(obj).attr('id') == defIdE) {
                        //Nothing do
                    }
                    else {
                        jQuery('#' + defIdE).removeAttr('checked');
                        if (jQuery('#' + idE).attr('checked')) {
                            jQuery('#' + defIdE).removeAttr('disabled');
                        }
                    }
                }

                jQuery('#' + defId).attr('disabled', 'disabled');
            }
        }
    }
}

function checkProvEnabled(obj) {

    if (jQuery(obj).attr('checked')) {
        if (jQuery(obj).attr('id') == 'googleProvEnabled') {

            if (!jQuery('#sfProvEnabled').attr('checked') && !jQuery('#scimProvEnabled').attr('checked') && !jQuery('#spmlProvEnabled').attr('checked')) {

                jQuery('#googleProvDefault').attr('checked', 'checked');
                jQuery('#googleProvDefault').attr('disabled', 'disabled');
            } else {
                jQuery('#googleProvDefault').removeAttr('disabled');
            }

            jQuery('#google_enable_logo').show();

        } else if (jQuery(obj).attr('id') == 'sfProvEnabled') {

            if (!jQuery('#googleProvEnabled').attr('checked') && !jQuery('#scimProvEnabled').attr('checked') && !jQuery('#spmlProvEnabled').attr('checked')) {

                jQuery('#sfProvDefault').attr('checked', 'checked');
                jQuery('#sfProvDefault').attr('disabled', 'disabled');
            } else {
                jQuery('#sfProvDefault').removeAttr('disabled');
            }

            jQuery('#sf_enable_logo').show();

        } else if (jQuery(obj).attr('id') == 'scimProvEnabled') {

            if (!jQuery('#googleProvEnabled').attr('checked') && !jQuery('#sfProvEnabled').attr('checked') && !jQuery('#spmlProvEnabled').attr('checked')) {

                jQuery('#scimProvDefault').attr('checked', 'checked');
                jQuery('#scimProvDefault').attr('disabled', 'disabled');
            } else {
                jQuery('#scimProvDefault').removeAttr('disabled');
            }

            jQuery('#scim_enable_logo').show();

        } else if (jQuery(obj).attr('id') == 'spmlProvEnabled') {

            if (!jQuery('#googleProvEnabled').attr('checked') && !jQuery('#sfProvEnabled').attr('checked') && !jQuery('#scimProvEnabled').attr('checked')) {

                jQuery('#spmlProvDefault').attr('checked', 'checked');
                jQuery('#spmlProvDefault').attr('disabled', 'disabled');
            } else {
                jQuery('#spmlProvDefault').removeAttr('disabled');
            }

            jQuery('#spml_enable_logo').show();
        }
    } else {
        if (jQuery(obj).attr('id') == 'googleProvEnabled') {

            if (jQuery('#sfProvEnabled').attr('checked') ||
                    jQuery('#spmlProvEnabled').attr('checked') ||
                    jQuery('#scimProvEnabled').attr('checked')) {

                if (jQuery('#googleProvDefault').attr('checked')) {
                    //jQuery('#googleProvEnabled').attr('checked','checked');
                    // CARBON.showWarningDialog("Make other enabled authenticator to default before disabling default authenticator");
                } else {
                    jQuery('#googleProvDefault').attr('disabled', 'disabled');
                    jQuery('#googleProvDefault').removeAttr('checked');
                    jQuery('#google_enable_logo').hide();
                }
            } else {
                jQuery('#googleProvDefault').attr('disabled', 'disabled');
                jQuery('#googleProvDefault').removeAttr('checked');
                jQuery('#google_enable_logo').hide();
            }

        } else if (jQuery(obj).attr('id') == 'sfProvEnabled') {

            if (jQuery('#googleProvEnabled').attr('checked') ||
                    jQuery('#spmlProvEnabled').attr('checked') ||
                    jQuery('#scimProvEnabled').attr('checked')) {

                if (jQuery('#sfProvDefault').attr('checked')) {
                    // jQuery('#sfProvEnabled').attr('checked','checked');
                    // CARBON.showWarningDialog("Make other enabled authenticator to default before disabling default authenticator");
                } else {
                    jQuery('#sfProvDefault').attr('disabled', 'disabled');
                    jQuery('#sfProvDefault').removeAttr('checked');
                    jQuery('#sf_enable_logo').hide();
                }
            } else {
                jQuery('#sfProvDefault').attr('disabled', 'disabled');
                jQuery('#sfProvDefault').removeAttr('checked');
                jQuery('#sf_enable_logo').hide();
            }

        } else if (jQuery(obj).attr('id') == 'scimProvEnabled') {

            if (jQuery('#sfProvEnabled').attr('checked') ||
                    jQuery('#spmlProvEnabled').attr('checked') ||
                    jQuery('#googleProvEnabled').attr('checked')) {

                if (jQuery('#scimProvDefault').attr('checked')) {
                    // jQuery('#scimProvEnabled').attr('checked','checked');
                    // CARBON.showWarningDialog("Make other enabled authenticator to default before disabling default authenticator");
                } else {
                    jQuery('#scimProvDefault').attr('disabled', 'disabled');
                    jQuery('#scimProvDefault').removeAttr('checked');
                    jQuery('#scim_enable_logo').hide();
                }
            } else {
                jQuery('#scimProvDefault').attr('disabled', 'disabled');
                jQuery('#scimProvDefault').removeAttr('checked');
                jQuery('#scim_enable_logo').hide();
            }

        } else if (jQuery(obj).attr('id') == 'spmlProvEnabled') {

            if (jQuery('#sfProvEnabled').attr('checked') ||
                    jQuery('#scimProvEnabled').attr('checked') ||
                    jQuery('#googleProvEnabled').attr('checked')) {

                if (jQuery('#spmlProvDefault').attr('checked')) {
                    // jQuery('#spmlProvEnabled').attr('checked','checked');
                    // CARBON.showWarningDialog("Make other enabled authenticator to default before disabling default authenticator");
                } else {
                    jQuery('#spmlProvDefault').attr('disabled', 'disabled');
                    jQuery('#spmlProvDefault').removeAttr('checked');
                    jQuery('#spml_enable_logo').hide();
                }
            } else {
                jQuery('#spmlProvDefault').attr('disabled', 'disabled');
                jQuery('#spmlProvDefault').removeAttr('checked');
                jQuery('#spml_enable_logo').hide();
            }
        }
    }
}

function checkProvDefault(obj) {
    if (jQuery(obj).attr('id') == 'googleProvDefault') {
        jQuery('#sfProvDefault').removeAttr('checked');
        jQuery('#scimProvDefault').removeAttr('checked');
        jQuery('#spmlProvDefault').removeAttr('checked');
        if (jQuery('#sfProvEnabled').attr('checked')) {
            jQuery('#sfProvDefault').removeAttr('disabled');
        }
        if (jQuery('#scimProvEnabled').attr('checked')) {
            jQuery('#scimProvDefault').removeAttr('disabled');
        }
        if (jQuery('#spmlProvEnabled').attr('checked')) {
            jQuery('#spmlProvDefault').removeAttr('disabled');
        }
        jQuery('#googleProvDefault').attr('disabled', 'disabled');
    } else if (jQuery(obj).attr('id') == 'sfProvDefault') {
        jQuery('#googleProvDefault').removeAttr('checked');
        jQuery('#scimProvDefault').removeAttr('checked');
        jQuery('#spmlProvDefault').removeAttr('checked');
        if (jQuery('#googleProvEnabled').attr('checked')) {
            jQuery('#googleProvDefault').removeAttr('disabled');
        }
        if (jQuery('#scimProvEnabled').attr('checked')) {
            jQuery('#scimProvDefault').removeAttr('disabled');
        }
        if (jQuery('#spmlProvEnabled').attr('checked')) {
            jQuery('#spmlProvDefault').removeAttr('disabled');
        }
        jQuery('#sfProvDefault').attr('disabled', 'disabled');
    } else if (jQuery(obj).attr('id') == 'scimProvDefault') {
        jQuery('#googleProvDefault').removeAttr('checked');
        jQuery('#sfProvDefault').removeAttr('checked');
        jQuery('#spmlProvDefault').removeAttr('checked');
        if (jQuery('#googleProvEnabled').attr('checked')) {
            jQuery('#googleProvDefault').removeAttr('disabled');
        }
        if (jQuery('#spmlProvEnabled').attr('checked')) {
            jQuery('#spmlProvDefault').removeAttr('disabled');
        }
        if (jQuery('#sfProvEnabled').attr('checked')) {
            jQuery('#sfProvDefault').removeAttr('disabled');
        }
        jQuery('#scimProvDefault').attr('disabled', 'disabled');
    } else if (jQuery(obj).attr('id') == 'spmlProvDefault') {
        jQuery('#googleProvDefault').removeAttr('checked');
        jQuery('#sfProvDefault').removeAttr('checked');
        jQuery('#scimProvDefault').removeAttr('checked');
        if (jQuery('#openIdEnabled').attr('checked')) {
            jQuery('#googleProvDefault').removeAttr('disabled');
        }
        if (jQuery('#googleProvEnabled').attr('checked')) {
            jQuery('#sfProvDefault').removeAttr('disabled');
        }
        if (jQuery('#scimProvEnabled').attr('checked')) {
            jQuery('#scimProvDefault').removeAttr('disabled');
        }
        jQuery('#spmlProvDefault').attr('disabled', 'disabled');
    }
}

function idpMgtUpdate() {
    if (doValidation()) {
        var allDeletedClaimStr = "";
        for (var i = 0; i < deleteClaimRows.length; i++) {
            if (i < deleteClaimRows.length - 1) {
                allDeletedClaimStr += deleteClaimRows[i] + ", ";
            } else {
                allDeletedClaimStr += deleteClaimRows[i] + "?";
            }
        }
        var allDeletedRoleStr = "";
        for (var i = 0; i < deletedRoleRows.length; i++) {
            if (i < deletedRoleRows.length - 1) {
                allDeletedRoleStr += deletedRoleRows[i] + ", ";
            } else {
                allDeletedRoleStr += deletedRoleRows[i] + "?";
            }
        }

        if (jQuery('#deletePublicCert').val() == 'true') {
            var confirmationMessage = 'Are you sure you want to delete the public certificate of ' +
                    jQuery('#idPName').val() + '?';
            if (jQuery('#certFile').val() != '') {
                confirmationMessage = confirmationMessage.replace("delete", "re-upload");
            }
            CARBON.showConfirmationDialog(confirmationMessage,
                    function () {
                        if (allDeletedClaimStr != "") {
                            CARBON.showConfirmationDialog('Are you sure you want to delete the claim URI(s) ' +
                                    allDeletedClaimStr,
                                    function () {
                                        if (allDeletedRoleStr != "") {
                                            CARBON.showConfirmationDialog('Are you sure you want to delete the ' +
                                                    'role(s) ' + allDeletedRoleStr,
                                                    function () {
                                                        if (jQuery('#deleteClaimMappings').val() == 'true') {
                                                            var confirmationMessage = 'Are you sure you want to ' +
                                                                    'delete the Claim URI Mappings of ' +
                                                                    jQuery('#idPName').val() + '?';
                                                            if (jQuery('#claimMappingFile').val() != '') {
                                                                confirmationMessage = confirmationMessage.replace("delete", "re-upload");
                                                            }
                                                            CARBON.showConfirmationDialog(confirmationMessage,
                                                                    function () {
                                                                        if (jQuery('#deleteRoleMappings').val() == 'true') {
                                                                            var confirmationMessage = 'Are you sure you want to ' +
                                                                                    'delete the Role Mappings of ' +
                                                                                    jQuery('#idPName').val() + '?';
                                                                            if (jQuery('#roleMappingFile').val() != '') {
                                                                                confirmationMessage = confirmationMessage.replace("delete", "re-upload");
                                                                            }
                                                                            CARBON.showConfirmationDialog(confirmationMessage,
                                                                                    function () {
                                                                                        doEditFinish();
                                                                                    },
                                                                                    function () {
                                                                                        location.href = "idp-mgt-edit.jsp?idPName=<%=idPName%>";
                                                                                    });
                                                                        } else {
                                                                            doEditFinish();
                                                                        }
                                                                    },
                                                                    function () {
                                                                        location.href = "idp-mgt-edit.jsp?idPName=<%=idPName%>";
                                                                    });
                                                        } else {
                                                            if (jQuery('#deleteRoleMappings').val() == 'true') {
                                                                var confirmationMessage = 'Are you sure you want to ' +
                                                                        'delete the Role Mappings of ' +
                                                                        jQuery('#idPName').val() + '?';
                                                                if (jQuery('#roleMappingFile').val() != '') {
                                                                    confirmationMessage = confirmationMessage.replace("delete", "re-upload");
                                                                }
                                                                CARBON.showConfirmationDialog(confirmationMessage,
                                                                        function () {
                                                                            doEditFinish();
                                                                        },
                                                                        function () {
                                                                            location.href = "idp-mgt-edit.jsp?idPName=<%=idPName%>";
                                                                        });
                                                            } else {
                                                                doEditFinish();
                                                            }
                                                        }
                                                    },
                                                    function () {
                                                        location.href = "idp-mgt-edit.jsp?idPName=<%=idPName%>";
                                                    });
                                        } else {
                                            if (jQuery('#deleteClaimMappings').val() == 'true') {
                                                var confirmationMessage = 'Are you sure you want to ' +
                                                        'delete the Claim URI mappings of ' +
                                                        jQuery('#idPName').val() + '?';
                                                if (jQuery('#claimMappingFile').val() != '') {
                                                    confirmationMessage = confirmationMessage.replace("delete", "re-upload");
                                                }
                                                CARBON.showConfirmationDialog(confirmationMessage,
                                                        function () {

                                                        },
                                                        function () {
                                                            location.href = "idp-mgt-edit.jsp?idPName=<%=idPName%>";
                                                        });
                                            } else {
                                                if (jQuery('#deleteRoleMappings').val() == 'true') {
                                                    var confirmationMessage = 'Are you sure you want to ' +
                                                            'delete the Role Mappings of ' +
                                                            jQuery('#idPName').val() + '?';
                                                    if (jQuery('#roleMappingFile').val() != '') {
                                                        confirmationMessage = confirmationMessage.replace("delete", "re-upload");
                                                    }
                                                    CARBON.showConfirmationDialog(confirmationMessage,
                                                            function () {
                                                                doEditFinish();
                                                            },
                                                            function () {
                                                                location.href = "idp-mgt-edit.jsp?idPName=<%=idPName%>";
                                                            });
                                                } else {
                                                    doEditFinish();
                                                }
                                            }
                                        }
                                    },
                                    function () {
                                        location.href = "idp-mgt-edit.jsp?idPName=<%=idPName%>";
                                    });
                        } else {
                            if (allDeletedRoleStr != "") {
                                CARBON.showConfirmationDialog('Are you sure you want to delete the ' +
                                        'role(s) ' + allDeletedRoleStr,
                                        function () {
                                            if (jQuery('#deleteClaimMappings').val() == 'true') {
                                                var confirmationMessage = 'Are you sure you want to ' +
                                                        'delete the Claim URI mappings of ' +
                                                        jQuery('#idPName').val() + '?';
                                                if (jQuery('#claimMappingFile').val() != '') {
                                                    confirmationMessage = confirmationMessage.replace("delete", "re-upload");
                                                }
                                                CARBON.showConfirmationDialog(confirmationMessage,
                                                        function () {

                                                        },
                                                        function () {
                                                            location.href = "idp-mgt-edit.jsp?idPName=<%=idPName%>";
                                                        });
                                            } else {
                                                if (jQuery('#deleteRoleMappings').val() == 'true') {
                                                    var confirmationMessage = 'Are you sure you want to ' +
                                                            'delete the Role Mappings of ' +
                                                            jQuery('#idPName').val() + '?';
                                                    if (jQuery('#roleMappingFile').val() != '') {
                                                        confirmationMessage = confirmationMessage.replace("delete", "re-upload");
                                                    }
                                                    CARBON.showConfirmationDialog(confirmationMessage,
                                                            function () {
                                                                doEditFinish();
                                                            },
                                                            function () {
                                                                location.href = "idp-mgt-edit.jsp?idPName=<%=idPName%>";
                                                            });
                                                } else {
                                                    doEditFinish();
                                                }
                                            }
                                        },
                                        function () {
                                            location.href = "idp-mgt-edit.jsp?idPName=<%=idPName%>";
                                        });
                            } else {
                                if (jQuery('#deleteClaimMappings').val() == 'true') {
                                    var confirmationMessage = 'Are you sure you want to ' +
                                            'delete the Claim URI mappings of ' +
                                            jQuery('#idPName').val() + '?';
                                    if (jQuery('#claimMappingFile').val() != '') {
                                        confirmationMessage = confirmationMessage.replace("delete", "re-upload");
                                    }
                                    CARBON.showConfirmationDialog(confirmationMessage,
                                            function () {
                                                if (jQuery('#deleteRoleMappings').val() == 'true') {
                                                    var confirmationMessage = 'Are you sure you want to ' +
                                                            'delete the Role Mappings of ' +
                                                            jQuery('#idPName').val() + '?';
                                                    if (jQuery('#roleMappingFile').val() != '') {
                                                        confirmationMessage = confirmationMessage.replace("delete", "re-upload");
                                                    }
                                                    CARBON.showConfirmationDialog(confirmationMessage,
                                                            function () {
                                                                doEditFinish();
                                                            },
                                                            function () {
                                                                location.href = "idp-mgt-edit.jsp?idPName=<%=idPName%>";
                                                            });
                                                } else {
                                                    doEditFinish();
                                                }
                                            },
                                            function () {
                                                location.href = "idp-mgt-edit.jsp?idPName=<%=idPName%>";
                                            });
                                } else {
                                    if (jQuery('#deleteRoleMappings').val() == 'true') {
                                        var confirmationMessage = 'Are you sure you want to ' +
                                                'delete the Role Mappings of ' +
                                                jQuery('#idPName').val() + '?';
                                        if (jQuery('#roleMappingFile').val() != '') {
                                            confirmationMessage = confirmationMessage.replace("delete", "re-upload");
                                        }
                                        CARBON.showConfirmationDialog(confirmationMessage,
                                                function () {
                                                    doEditFinish();
                                                },
                                                function () {
                                                    location.href = "idp-mgt-edit.jsp?idPName=<%=idPName%>";
                                                });
                                    } else {
                                        doEditFinish();
                                    }
                                }
                            }
                        }
                    },
                    function () {
                        location.href = "idp-mgt-edit.jsp?idPName=<%=idPName%>";
                    });
        } else {
            if (allDeletedClaimStr != "") {
                CARBON.showConfirmationDialog('Are you sure you want to delete the claim URI(s) ' +
                        allDeletedClaimStr,
                        function () {
                            if (allDeletedRoleStr != "") {
                                CARBON.showConfirmationDialog('Are you sure you want to delete the ' +
                                        'role(s) ' + allDeletedRoleStr,
                                        function () {
                                            if (jQuery('#deleteClaimMappings').val() == 'true') {
                                                var confirmationMessage = 'Are you sure you want to ' +
                                                        'delete the Claim URI mappings of ' +
                                                        jQuery('#idPName').val() + '?';
                                                if (jQuery('#claimMappingFile').val() != '') {
                                                    confirmationMessage = confirmationMessage.replace("delete", "re-upload");
                                                }
                                                CARBON.showConfirmationDialog(confirmationMessage,
                                                        function () {

                                                        },
                                                        function () {
                                                            location.href = "idp-mgt-edit.jsp?idPName=<%=idPName%>";
                                                        });
                                            } else {
                                                if (jQuery('#deleteRoleMappings').val() == 'true') {
                                                    var confirmationMessage = 'Are you sure you want to ' +
                                                            'delete the Role Mappings of ' +
                                                            jQuery('#idPName').val() + '?';
                                                    if (jQuery('#roleMappingFile').val() != '') {
                                                        confirmationMessage = confirmationMessage.replace("delete", "re-upload");
                                                    }
                                                    CARBON.showConfirmationDialog(confirmationMessage,
                                                            function () {
                                                                doEditFinish();
                                                            },
                                                            function () {
                                                                location.href = "idp-mgt-edit.jsp?idPName=<%=idPName%>";
                                                            });
                                                } else {
                                                    doEditFinish();
                                                }
                                            }
                                        },
                                        function () {
                                            location.href = "idp-mgt-edit.jsp?idPName=<%=idPName%>";
                                        });
                            } else {
                                if (jQuery('#deleteClaimMappings').val() == 'true') {
                                    var confirmationMessage = 'Are you sure you want to ' +
                                            'delete the Claim URI mappings of ' +
                                            jQuery('#idPName').val() + '?';
                                    if (jQuery('#claimMappingFile').val() != '') {
                                        confirmationMessage = confirmationMessage.replace("delete", "re-upload");
                                    }
                                    CARBON.showConfirmationDialog(confirmationMessage,
                                            function () {
                                                if (jQuery('#deleteRoleMappings').val() == 'true') {
                                                    var confirmationMessage = 'Are you sure you want to ' +
                                                            'delete the Role Mappings of ' +
                                                            jQuery('#idPName').val() + '?';
                                                    if (jQuery('#roleMappingFile').val() != '') {
                                                        confirmationMessage = confirmationMessage.replace("delete", "re-upload");
                                                    }
                                                    CARBON.showConfirmationDialog(confirmationMessage,
                                                            function () {
                                                                doEditFinish();
                                                            },
                                                            function () {
                                                                location.href = "idp-mgt-edit.jsp?idPName=<%=idPName%>";
                                                            });
                                                } else {
                                                    doEditFinish();
                                                }
                                            },
                                            function () {
                                                location.href = "idp-mgt-edit.jsp?idPName=<%=idPName%>";
                                            });
                                } else {
                                    if (jQuery('#deleteRoleMappings').val() == 'true') {
                                        var confirmationMessage = 'Are you sure you want to ' +
                                                'delete the Role Mappings of ' +
                                                jQuery('#idPName').val() + '?';
                                        if (jQuery('#roleMappingFile').val() != '') {
                                            confirmationMessage = confirmationMessage.replace("delete", "re-upload");
                                        }
                                        CARBON.showConfirmationDialog(confirmationMessage,
                                                function () {
                                                    doEditFinish();
                                                },
                                                function () {
                                                    location.href = "idp-mgt-edit.jsp?idPName=<%=idPName%>";
                                                });
                                    } else {
                                        doEditFinish();
                                    }
                                }
                            }
                        },
                        function () {
                            location.href = "idp-mgt-edit.jsp?idPName=<%=idPName%>";
                        });
            } else {
                if (allDeletedRoleStr != "") {
                    CARBON.showConfirmationDialog('Are you sure you want to delete the ' +
                            'role(s) ' + allDeletedRoleStr,
                            function () {
                                if (jQuery('#deleteClaimMappings').val() == 'true') {
                                    var confirmationMessage = 'Are you sure you want to ' +
                                            'delete the Claim URI mappings of ' +
                                            jQuery('#idPName').val() + '?';
                                    if (jQuery('#claimMappingFile').val() != '') {
                                        confirmationMessage = confirmationMessage.replace("delete", "re-upload");
                                    }
                                    CARBON.showConfirmationDialog(confirmationMessage,
                                            function () {
                                                if (jQuery('#deleteRoleMappings').val() == 'true') {
                                                    var confirmationMessage = 'Are you sure you want to ' +
                                                            'delete the Role Mappings of ' +
                                                            jQuery('#idPName').val() + '?';
                                                    if (jQuery('#roleMappingFile').val() != '') {
                                                        confirmationMessage = confirmationMessage.replace("delete", "re-upload");
                                                    }
                                                    CARBON.showConfirmationDialog(confirmationMessage,
                                                            function () {
                                                                doEditFinish();
                                                            },
                                                            function () {
                                                                location.href = "idp-mgt-edit.jsp?idPName=<%=idPName%>";
                                                            });
                                                } else {
                                                    doEditFinish();
                                                }
                                            },
                                            function () {
                                                location.href = "idp-mgt-edit.jsp?idPName=<%=idPName%>";
                                            });
                                } else {
                                    if (jQuery('#deleteRoleMappings').val() == 'true') {
                                        var confirmationMessage = 'Are you sure you want to ' +
                                                'delete the Role Mappings of ' +
                                                jQuery('#idPName').val() + '?';
                                        if (jQuery('#roleMappingFile').val() != '') {
                                            confirmationMessage = confirmationMessage.replace("delete", "re-upload");
                                        }
                                        CARBON.showConfirmationDialog(confirmationMessage,
                                                function () {
                                                    doEditFinish();
                                                },
                                                function () {
                                                    location.href = "idp-mgt-edit.jsp?idPName=<%=idPName%>";
                                                });
                                    } else {
                                        doEditFinish();
                                    }
                                }
                            },
                            function () {
                                location.href = "idp-mgt-edit.jsp?idPName=<%=idPName%>";
                            });
                } else {
                    if (jQuery('#deleteClaimMappings').val() == 'true') {
                        var confirmationMessage = 'Are you sure you want to ' +
                                'delete the Claim URI mappings of ' +
                                jQuery('#idPName').val() + '?';
                        if (jQuery('#claimMappingFile').val() != '') {
                            confirmationMessage = confirmationMessage.replace("delete", "re-upload");
                        }
                        CARBON.showConfirmationDialog(confirmationMessage,
                                function () {
                                    if (jQuery('#deleteRoleMappings').val() == 'true') {
                                        var confirmationMessage = 'Are you sure you want to ' +
                                                'delete the Role Mappings of ' +
                                                jQuery('#idPName').val() + '?';
                                        if (jQuery('#roleMappingFile').val() != '') {
                                            confirmationMessage = confirmationMessage.replace("delete", "re-upload");
                                        }
                                        CARBON.showConfirmationDialog(confirmationMessage,
                                                function () {
                                                    doEditFinish();
                                                },
                                                function () {
                                                    location.href = "idp-mgt-edit.jsp?idPName=<%=idPName%>";
                                                });
                                    } else {
                                        doEditFinish();
                                    }
                                },
                                function () {
                                    location.href = "idp-mgt-edit.jsp?idPName=<%=idPName%>";
                                });
                    } else {
                        if (jQuery('#deleteRoleMappings').val() == 'true') {
                            var confirmationMessage = 'Are you sure you want to ' +
                                    'delete the Role Mappings of ' +
                                    jQuery('#idPName').val() + '?';
                            if (jQuery('#roleMappingFile').val() != '') {
                                confirmationMessage = confirmationMessage.replace("delete", "re-upload");
                            }
                            CARBON.showConfirmationDialog(confirmationMessage,
                                    function () {
                                        doEditFinish();
                                    },
                                    function () {
                                        location.href = "idp-mgt-edit.jsp?idPName=<%=idPName%>";
                                    });
                        } else {
                            doEditFinish();
                        }
                    }
                }
            }
        }
    }
}

function doEditFinish() {
    jQuery('#primary').removeAttr('disabled');
    jQuery('#openIdEnabled').removeAttr('disabled');
    jQuery('#saml2SSOEnabled').removeAttr('disabled');
    jQuery('#oidcEnabled').removeAttr('disabled');
    jQuery('#passiveSTSEnabled').removeAttr('disabled');
    jQuery('#fbAuthEnabled').removeAttr('disabled');
    jQuery('#openIdDefault').removeAttr('disabled');
    jQuery('#saml2SSODefault').removeAttr('disabled');
    jQuery('#oidcDefault').removeAttr('disabled');
    jQuery('#passiveSTSDefault').removeAttr('disabled');
    jQuery('#fbAuthDefault').removeAttr('disabled');
    jQuery('#googleProvDefault').removeAttr('disabled');
    jQuery('#spmlProvDefault').removeAttr('disabled');
    jQuery('#sfProvDefault').removeAttr('disabled');
    jQuery('#scimProvDefault').removeAttr('disabled');

    for (id in getEnabledCustomAuth()) {
        var defId = '#' + id.replace("_Enabled", "_Default");
        jQuery(defId).removeAttr('disabled');
    }
    <% if(idPName == null || idPName.equals("")){ %>
    jQuery('#idp-mgt-edit-form').attr('action', 'idp-mgt-add-finish.jsp');
    <% } %>
    jQuery('#idp-mgt-edit-form').submit();
}
function idpMgtCancel() {
    location.href = "idp-mgt-list.jsp"
}

function showHidePassword(element, inputId) {
    if ($(element).text() == 'Show') {
        document.getElementById(inputId).type = 'text';
        $(element).text('Hide');
    } else {
        document.getElementById(inputId).type = 'password';
        $(element).text('Show');
    }
}

function emailValidator(name) {
    var errorMsg = "";
    var emailPattern = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/;
    if (name == "") {
        errorMsg = "null";
    } else if (!name.match(new RegExp(emailPattern))) {
        errorMsg = "notValied";
    }
    return errorMsg;
}

function doValidation() {
    var reason = "";
    reason = validateEmpty("idPName");
    if (reason != "") {
        CARBON.showWarningDialog("Name of IdP cannot be empty");
        return false;
    }

    if (jQuery('#openIdEnabled').attr('checked')) {

        if ($('#openIdUrl').val() == "") {
            CARBON.showWarningDialog('OpenID Server URL cannot be empty');
            return false;
        }
    }

    if (jQuery('#saml2SSOEnabled').attr('checked')) {

        if ($('#idPEntityId').val() == "") {
            CARBON.showWarningDialog('Identity Provider Entity Id cannot be empty');
            return false;
        }

        if ($('#spEntityId').val() == "") {
            CARBON.showWarningDialog('Service Provider Entity Id cannot be empty');
            return false;
        }

        if ($('#ssoUrl').val() == "") {
            CARBON.showWarningDialog('SSO URL cannot be empty');
            return false;
        }

    }

    if (jQuery('#oidcEnabled').attr('checked')) {

        if ($('#authzUrl').val() == "") {
            CARBON.showWarningDialog('OAuth2/OpenId  Authorization Endpoint URL cannot be empty');
            return false;
        }

        if ($('#tokenUrl').val() == "") {
            CARBON.showWarningDialog('OAuth2/OpenId Token Endpoint URL cannot be empty');
            return false;
        }

        if ($('#clientId').val() == "") {
            CARBON.showWarningDialog('OAuth2/OpenId Client Id cannot be empty');
            return false;
        }

        if ($('#clientSecret').val() == "") {
            CARBON.showWarningDialog('OAuth2/OpenId Client Secret cannot be empty');
            return false;
        }

    }

    if (jQuery('#passiveSTSEnabled').attr('checked')) {

        if ($('#passiveSTSRealm').val() == "") {
            CARBON.showWarningDialog('Passive STS Realm cannot be empty');
            return false;
        }

        if ($('#passiveSTSUrl').val() == "") {
            CARBON.showWarningDialog('Passive STS URL cannot be empty');
            return false;
        }
    }

    if (jQuery('#fbAuthEnabled').attr('checked')) {

        if ($('#fbClientId').val() == "") {
            CARBON.showWarningDialog('Facebook Client Id cannot be empty');
            return false;
        }

        if ($('#fbClientSecret').val() == "") {
            CARBON.showWarningDialog('Facebook Client Secret cannot be empty');
            return false;
        }
    }


    if (jQuery('#googleProvEnabled').attr('checked')) {

        if ($('#google_prov_domain_name').val() == "") {
            CARBON.showWarningDialog('Google Domain cannot be empty');
            return false;
        }


        var errorMsg = emailValidator($('#google_prov_service_acc_email').val());
        if (errorMsg == "null") {
            CARBON.showWarningDialog('Google connector Service Account Email cannot be empty');
            return false;
        } else if (errorMsg == "notValied") {
            CARBON.showWarningDialog('Google connector Service Account Email is not valid');
            return false;
        }

        var errorMsgAdmin = emailValidator($('#google_prov_admin_email').val());
        if (errorMsgAdmin == "null") {
            CARBON.showWarningDialog('Google connector Administrator\'s Email cannot be empty');
            return false;
        } else if (errorMsgAdmin == "notValied") {
            CARBON.showWarningDialog('Google connector Administrator\'s Email is not valid');
            return false;
        }


        if ($('#google_prov_application_name').val() == "") {
            CARBON.showWarningDialog('Google connector Application Name cannot be empty');
            return false;
        }

        if ($('#google_prov_email_claim_dropdown').val() == "") {
            CARBON.showWarningDialog('Google connector Primary Email claim URI should be selected ');
            return false;
        }

        if ($('#google_prov_givenname_claim_dropdown').val() == "") {
            CARBON.showWarningDialog('Google connector Given Name claim URI should be selected ');
            return false;
        }

        if ($('#google_prov_familyname_claim_dropdown').val() == "") {
            CARBON.showWarningDialog('Google connector Family Name claim URI should be selected ');
            return false;
        }

    }

    if (jQuery('#sfProvEnabled').attr('checked')) {

        if ($('#sf-api-version').val() == "") {
            CARBON.showWarningDialog('Salesforce Provisioning Configuration API version cannot be empty');
            return false;
        }

        if ($('#sf-domain-name').val() == "") {
            CARBON.showWarningDialog('Salesforce Provisioning Configuration Domain Name cannot be empty');
            return false;
        }

        if ($('#sf-clientid').val() == "") {
            CARBON.showWarningDialog('Salesforce Provisioning Configuration Client Id cannot be empty');
            return false;
        }

        if ($('#sf-client-secret').val() == "") {
            CARBON.showWarningDialog('Salesforce Provisioning Configuration Client Secret cannot be empty');
            return false;
        }

        if ($('#sf-username').val() == "") {
            CARBON.showWarningDialog('Salesforce Provisioning Configuration Username cannot be empty');
            return false;
        }

        if ($('#sf-password').val() == "") {
            CARBON.showWarningDialog('Salesforce Provisioning Configuration Password cannot be empty');
            return false;
        }

        if ($('#sf-token-endpoint').val() == "") {
            CARBON.showWarningDialog('Salesforce Provisioning Configuration Oauth2 Token Endpoint cannot be empty');
            return false;
        }
    }


    if (jQuery('#scimProvEnabled').attr('checked')) {

        if ($('#scim-username').val() == "") {
            CARBON.showWarningDialog('Scim Configuration username cannot be empty');
            return false;
        }

        if ($('#scim-password').val() == "") {
            CARBON.showWarningDialog('Scim Configuration password cannot be empty');
            return false;
        }

        if ($('#scim-user-ep').val() == "") {
            CARBON.showWarningDialog('Scim Configuration User endpoint cannot be empty');
            return false;
        }
    }

    if (jQuery('#spmlProvEnabled').attr('checked')) {

        if ($('#spml-ep').val() == "") {
            CARBON.showWarningDialog('SPML Endpoint cannot be empty');
            return false;
        }

        if ($('#spml-oc').val() == "") {
            CARBON.showWarningDialog('SPML Object class cannot be empty');
            return false;
        }

    }

    for (var i = 0; i <= claimRowId; i++) {
        if (document.getElementsByName('claimrowname_' + i)[0] != null) {
            reason = validateEmpty('claimrowname_' + i);
            if (reason != "") {
                CARBON.showWarningDialog("Claim URI strings cannot be of zero length");
                return false;
            }
        }
    }

    for (var i = 0; i <= roleRowId; i++) {
        if (document.getElementsByName('rolerowname_' + i)[0] != null) {
            reason = validateEmpty('rolerowname_' + i);
            if (reason != "") {
                CARBON.showWarningDialog("Role name strings cannot be of zero length");
                return false;
            }
        }
    }

    return true;
}
</script>

<fmt:bundle basename="org.wso2.carbon.idp.mgt.ui.i18n.Resources">
<div id="middle">
<h2>
    <fmt:message key='add.identity.provider'/>
</h2>

<div id="workArea">
<form id="idp-mgt-edit-form" name="idp-mgt-edit-form" method="post" action="idp-mgt-edit-finish.jsp"
      enctype="multipart/form-data">
<div class="sectionSeperator togglebleTitle"><fmt:message key='identity.provider.info'/></div>
<div class="sectionSub">
    <table class="carbonFormTable">
        <tr>
            <td class="leftCol-med labelField"><fmt:message key='name'/>:<span class="required">*</span></td>
            <td>
                <input id="idPName" name="idPName" type="text" value="<%=idPName%>" autofocus/>
                <%if (identityProvider != null && identityProvider.getEnable()) { %>
                <input id="enable" name="enable" type="hidden" value="1">
                <%} %>

                <div class="sectionHelp">
                    <fmt:message key='name.help'/>
                </div>
            </td>
        </tr>

        <tr>
            <td class="leftCol-med labelField"><fmt:message key='idp.display.name'/>:</td>
            <td>
                <input id="idpDisplayName" name="idpDisplayName" type="text" value="<%=idpDisplayName%>" autofocus/>

                <div class="sectionHelp">
                    <fmt:message key='idp.display.name.help'/>
                </div>
            </td>
        </tr>

        <tr>
            <td class="leftCol-med labelField"><fmt:message key='description'/></td>
            <td>
                <input id="idPDescription" name="idPDescription" type="text" value="<%=description%>" autofocus/>

                <div class="sectionHelp">
                    <fmt:message key='description.help'/>
                </div>
            </td>
        </tr>

        <tr>
            <td class="leftCol-med labelField">
                <label for="federationHub"><fmt:message key='federation.hub.identity.proider'/></label>
            </td>
            <td>
                <div class="sectionCheckbox">
                    <input type="checkbox" id="federation_hub_idp"
                           name="federation_hub_idp" <%=federationHubIdp ? "checked" : "" %>>
                                <span style="display:inline-block" class="sectionHelp">
                                    <fmt:message key='federation.hub.identity.proider.help'/>
                                </span>
                </div>
            </td>
        </tr>


        <tr>
            <td class="leftCol-med labelField"><fmt:message key='home.realm.id'/>:</td>
            <td>
                <input id="realmId" name="realmId" type="text" value="<%=realmId%>" autofocus/>

                <div class="sectionHelp">
                    <fmt:message key='home.realm.id.help'/>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField"><fmt:message key='certificate'/>:</td>
            <td>
                <input id="certFile" name="certFile" type="file"/>

                <div class="sectionHelp">
                    <fmt:message key='certificate.help'/>
                </div>
                <div id="publicCertDiv">
                    <% if (certData != null) { %>
                    <a id="publicCertDeleteLink" class="icon-link"
                       style="margin-left:0;background-image:url(images/delete.gif);"><fmt:message
                            key='public.cert.delete'/></a>

                    <div style="clear:both"></div>
                    <table class="styledLeft">
                        <thead>
                        <tr>
                            <th><fmt:message key='issuerdn'/></th>
                            <th><fmt:message key='subjectdn'/></th>
                            <th><fmt:message key='notafter'/></th>
                            <th><fmt:message key='notbefore'/></th>
                            <th><fmt:message key='serialno'/></th>
                            <th><fmt:message key='version'/></th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr>
                            <td><%
                                String issuerDN = "";
                                if (certData.getIssuerDN() != null) {
                                    issuerDN = certData.getIssuerDN();
                                }
                            %><%=issuerDN%>
                            </td>
                            <td><%
                                String subjectDN = "";
                                if (certData.getSubjectDN() != null) {
                                    subjectDN = certData.getSubjectDN();
                                }
                            %><%=subjectDN%>
                            </td>
                            <td><%
                                String notAfter = "";
                                if (certData.getNotAfter() != null) {
                                    notAfter = certData.getNotAfter();
                                }
                            %><%=notAfter%>
                            </td>
                            <td><%
                                String notBefore = "";
                                if (certData.getNotBefore() != null) {
                                    notBefore = certData.getNotBefore();
                                }
                            %><%=notBefore%>
                            </td>
                            <td><%
                                String serialNo = "";
                                if (certData.getSerialNumber() != null) {
                                    serialNo = certData.getSerialNumber().toString();
                                }
                            %><%=serialNo%>
                            </td>
                            <td><%=certData.getVersion()%>
                            </td>
                        </tr>
                        </tbody>
                    </table>
                    <% } %>
                </div>
            </td>
        </tr>


        <tr>
            <td class="leftCol-med labelField"><fmt:message key='resident.idp.alias'/>:</td>
            <td>
                <input id="tokenEndpointAlias" name="tokenEndpointAlias" type="text" value="<%=idPAlias%>" autofocus/>

                <div class="sectionHelp">
                    <fmt:message key='resident.idp.alias.help'/>
                </div>
            </td>
        </tr>

    </table>
</div>


<h2 id="claim_config_head" class="sectionSeperator trigger active"><a href="#"><fmt:message
        key="claim.config.head"/></a>
</h2>

<div class="toggle_container sectionSub" style="margin-bottom:10px;" id="claimConfig">

<h2 id="basic_claim_config_head" class="sectionSeperator trigger active" style="background-color: beige;">
    <a href="#"><fmt:message key="basic.cliam.config"/></a>
</h2>

<div class="toggle_container sectionSub" style="margin-bottom:10px;" id="baisClaimLinkRow">

    <table>


        <tr>
            <td class="leftCol-med labelField"><fmt:message key='select_dialet_type'/>:</td>
            <td>
                <label style="display:block">
                    <input type="radio" id="choose_dialet_type1" name="choose_dialet_type_group"
                           value="choose_dialet_type1" <% if (!isCustomClaimEnabled) { %> checked="checked" <% } %> />
                    Use Local Claim Dialect
                </label>
                <label style="display:block">
                    <input type="radio" id="choose_dialet_type2" name="choose_dialet_type_group"
                           value="choose_dialet_type2"  <% if (isCustomClaimEnabled) { %> checked="checked" <% } %> />
                    Define Custom Claim Dialect
                </label>
            </td>
        </tr>
        <tr>


            <td class="leftCol-med labelField customClaim"><fmt:message key='claimURIs'/>:</td>

            <td class="customClaim">
                <a id="claimAddLink" class="icon-link"
                   style="margin-left:0;background-image:url(images/add.gif);"><fmt:message key='add.claim'/></a>

                <div style="clear:both"></div>
                <div class="sectionHelp">
                    <fmt:message key='claimURIs.help'/>
                </div>
                <table class="styledLeft" id="claimAddTable" style="display:none">
                    <thead>
                    <tr>
                        <th class="leftCol-big"><fmt:message key='idp.claim'/></th>
                        <th><fmt:message key='wso2.claim'/></th>
                        <th><fmt:message key='actions'/></th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        if (claimMappings != null && claimMappings.length > 0) {
                    %>
                    <script>
                        $(
                                jQuery('#claimAddTable'))
                                .toggle();
                    </script>
                    <% for (int i = 0; i < claimMappings.length; i++) { %>
                    <tr>
                        <td><input type="text" style=" width: 90%; " class="claimrow"
                                   value="<%=claimMappings[i].getRemoteClaim().getClaimUri()%>" id="claimrowid_<%=i%>"
                                   name="claimrowname_<%=i%>"/></td>
                        <td>
                            <select id="claimrow_id_wso2_<%=i%>" class="claimrow_wso2" name="claimrow_name_wso2_<%=i%>">
                                <option value="">--- Select Claim URI ---</option>
                                        <% for(String wso2ClaimName : claimUris) { 
													if(claimMappings[i].getLocalClaim().getClaimUri() != null && claimMappings[i].getLocalClaim().getClaimUri().equals(wso2ClaimName)){	%>
                                <option selected="selected" value="<%=wso2ClaimName%>"><%=wso2ClaimName%>
                                </option>
                                        <%
													} else{ %>
                                <option value="<%=wso2ClaimName%>"><%=wso2ClaimName%>
                                </option>
                                        <%}
												}%>


                        </td>

                        <td>
                            <a title="<fmt:message key='delete.claim'/>"
                               onclick="deleteClaimRow(this);return false;"
                               href="#"
                               class="icon-link"
                               style="background-image: url(images/delete.gif)">
                                <fmt:message key='delete'/>
                            </a>
                        </td>
                    </tr>

                    <% } %>
                    <% } %>

                    </tbody>
                </table>
            </td>
        </tr>

        <tr>
            <td>

                <% if (claimMappings != null) { %>
                <input type="hidden" id="claimrow_id_count" name="claimrow_name_count"
                       value="<%=claimMappings.length%>">
                <% } else { %>
                <input type="hidden" id="claimrow_id_count" name="claimrow_name_count" value="0">
                <% } %>

            </td>
        </tr>

        <tr>
            <td class="leftCol-med labelField"><fmt:message key='user.id.claim.uri'/>:</td>
            <td>
                <select id="user_id_claim_dropdown" name="user_id_claim_dropdown"></select>

                <div class="sectionHelp">
                    <fmt:message key='user.id.claim.uri.help'/>
                </div>
            </td>
        </tr>
        <tr class="role_claim">
            <td class="leftCol-med labelField"><fmt:message key='role.claim.uri'/>:</td>
            <td>
                <select id="role_claim_dropdown" name="role_claim_dropdown"></select>

                <div class="sectionHelp">
                    <fmt:message key='role.claim.uri.help'/>
                </div>
            </td>
        </tr>
    </table>
</div>

<h2 id="advanced_claim_config_head" class="sectionSeperator trigger active" style="background-color: beige;">
    <a href="#"><fmt:message key="advanced.cliam.config"/></a>
</h2>

<div class="toggle_container sectionSub" style="margin-bottom:10px;" id="advancedClaimLinkRow">
    <table style="width: 100%">
        <tr>

            <td colspan="2">
                <table>
                    <tr>
                        <td class="leftCol-med labelField"><fmt:message key='role.claim.filter'/>:</td>
                        <td>
                            <select id="idpClaimsList2" name="idpClaimsList2" style="float: left;"></select>
                            <a id="advancedClaimMappingAddLink" class="icon-link"
                               style="background-image: url(images/add.gif);"><fmt:message
                                    key='button.add.advanced.claim'/></a>

                            <div style="clear: both"/>
                            <div class="sectionHelp">
                                <fmt:message key='help.advanced.claim.mapping'/>
                            </div>
                        </td>
                    </tr>
                </table>
                <table class="styledLeft" id="advancedClaimMappingAddTable" style="display:none">
                    <thead>
                    <tr>
                        <th class="leftCol-big">Claim URI</th>
                        <th class="leftCol-big">Default Value</th>
                        <th>Actions</th>
                    </tr>
                    </thead>
                    <tbody>

                    <%
                        if (claimMappings != null && claimMappings.length > 0) {
                    %>
                    <script>
                        $(
                                jQuery('#advancedClaimMappingAddTable'))
                                .show();
                    </script>
                    <% for (int i = 0; i < claimMappings.length; i++) {
                        if (!isCustomClaimEnabled) {
                    %>
                    <tr>
                        <td><input type="text" style="width: 99%;" class="claimrow"
                                   value="<%=claimMappings[i].getLocalClaim().getClaimUri()%>"
                                   id="advancnedIdpClaim_<%=i%>" name="advancnedIdpClaim_<%=i%>"/></td>
                        <td><input type="text" style="width: 99%;" class="claimrow"
                                   value="<%=claimMappings[i].getDefaultValue() != null ? claimMappings[i].getDefaultValue() : "" %>"
                                   id="advancedDefault_<%=i%>" name="advancedDefault_<%=i%>"/></td>
                        <td>
                            <a title="<fmt:message key='delete.claim'/>"
                               onclick="deleteClaimRow(this);return false;"
                               href="#"
                               class="icon-link"
                               style="background-image: url(images/delete.gif)">
                                <fmt:message key='delete'/>
                            </a>
                        </td>
                    </tr>

                    <% } else {

                        if (claimMappings[i].getRequested()) {
                    %>
                    <tr>
                        <td><input type="text" style="width: 99%;" class="claimrow"
                                   value="<%=claimMappings[i].getRemoteClaim().getClaimUri()%>"
                                   id="advancnedIdpClaim_<%=i%>" name="advancnedIdpClaim_<%=i%>"/></td>
                        <td><input type="text" style="width: 99%;" class="claimrow"
                                   value="<%=claimMappings[i].getDefaultValue() != null ? claimMappings[i].getDefaultValue() : "" %>"
                                   id="advancedDefault_<%=i%>" name="advancedDefault_<%=i%>"/></td>
                        <td>
                            <a title="<fmt:message key='delete.claim'/>"
                               onclick="deleteClaimRow(this);return false;"
                               href="#"
                               class="icon-link"
                               style="background-image: url(images/delete.gif)">
                                <fmt:message key='delete'/>
                            </a>
                        </td>
                    </tr>

                    <%
                                }

                            }

                        }%>
                    <% } %>

                    </tbody>
                </table>
            </td>
        </tr>

        <tr>
            <td>
                <%
                    if (claimMappings != null) {
                %> <input type="hidden" id="advanced_claim_id_count" name="advanced_claim_id_count"
                          value="<%=claimMappings.length%>"> <% } else { %> <input
                    type="hidden" id="advanced_claim_id_count" name="advanced_claim_id_count" value="0">
                <% } %>

            </td>
        </tr>
    </table>
</div>


</div>


<h2 id="role_permission_config_head" class="sectionSeperator trigger active">
    <a href="#"><fmt:message key="role.config.head"/></a>
</h2>

<div class="toggle_container sectionSub" style="margin-bottom:10px;" id="roleConfig">
    <table>
        <tr>
            <td class="leftCol-med labelField"><fmt:message key='roles'/>:</td>
            <td>
                <a id="roleAddLink" class="icon-link"
                   style="margin-left:0;background-image:url(images/add.gif);"><fmt:message key='add.role.mapping'/></a>

                <div style="clear:both"/>
                <div class="sectionHelp">
                    <fmt:message key='roles.mapping.help'/>
                </div>
                <table class="styledLeft" id="roleAddTable" style="display:none">
                    <thead>
                    <tr>
                        <th class="leftCol-big"><fmt:message key='idp.role'/></th>
                        <th class="leftCol-big"><fmt:message key='local.role'/></th>
                        <th><fmt:message key='actions'/></th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        if (roleMappings != null && roleMappings.length > 0) {
                    %>
                    <script>
                        $(
                                jQuery('#roleAddTable'))
                                .toggle();
                    </script>
                    <%
                        for (int i = 0; i < roleMappings.length; i++) {
                    %>
                    <tr>
                        <td><input type="text" value="<%=roleMappings[i].getRemoteRole()%>" id="rolerowname_<%=i%>"
                                   name="rolerowname_<%=i%>"/></td>
                        <td><input type="text" value="<%=UserCoreUtil.addDomainToName(roleMappings[i].getLocalRole().getLocalRoleName(), roleMappings[i].getLocalRole().getUserStoreId())%>" id="localrowname_<%=i%>" name="localrowname_<%=i%>"/></td>
                        <td>
                            <a title="<fmt:message key='delete.role'/>"
                               onclick="deleteRoleRow(this);return false;"
                               href="#"
                               class="icon-link"
                               style="background-image: url(images/delete.gif)">
                                <fmt:message key='delete'/>
                            </a>
                        </td>
                    </tr>
                    <%
                        }
                    %>
                    <%
                        }
                    %>


                    </tbody>
                </table>
            </td>
        </tr>

        <tr>
            <td>
                <%
                    if (roleMappings != null) {
                %> <input type="hidden" id="rolemappingrow_id_count" name="rolemappingrow_name_count"
                          value="<%=roleMappings.length%>"> <% } else { %> <input
                    type="hidden" id="rolemappingrow_id_count"
                    name="rolemappingrow_name_count" value="0"> <% } %>

            </td>
        </tr>

        <tr>
            <td class="leftCol-med labelField"><fmt:message key='provisioning.role'/>:</td>
            <td>
                <input id="idpProvisioningRole" class="leftCol-med" name="idpProvisioningRole" type="text"
                       value="<%=provisioningRole%>"/>

                <div class="sectionHelp">
                    <fmt:message key='provisioning.role.help'/>
                </div>
            </td>
        </tr>

    </table>
</div>


<h2 id="out_bound_auth_head" class="sectionSeperator trigger active">
    <a href="#"><fmt:message key="out.bound.auth.config"/></a>
</h2>

<div class="toggle_container sectionSub" style="margin-bottom:10px;" id="outBoundAuth">

<h2 id="openid_head" class="sectionSeperator trigger active" style="background-color: beige;">
    <a href="#"><fmt:message key="openid.config"/></a>

    <div id="openid_enable_logo" class="enablelogo" style="float:right;padding-right: 5px;padding-top: 5px;"><img
            src="images/ok.png" alt="enable" width="16" height="16"></div>
</h2>
<div class="toggle_container sectionSub" style="margin-bottom:10px;" id="openIdLinkRow">
    <table class="carbonFormTable">
        <tr>
            <td class="leftCol-med labelField">
                <label for="openIdEnabled"><fmt:message key='openid.enabled'/></label>
            </td>
            <td>
                <div class="sectionCheckbox">
                    <input id="openIdEnabled" name="openIdEnabled" type="checkbox" <%=openIdEnabledChecked%>
                           onclick="checkEnabled(this);"/>
                                <span style="display:inline-block" class="sectionHelp">
                                    <fmt:message key='openid.enabled.help'/>
                                </span>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField">
                <label for="openIdDefault"><fmt:message key='openid.default'/></label>
            </td>
            <td>
                <div class="sectionCheckbox">
                    <input id="openIdDefault" name="openIdDefault"
                           type="checkbox" <%=openIdDefaultChecked%> <%=openIdDefaultDisabled%>
                           onclick="checkDefault(this);"/>
                                <span style="display:inline-block" class="sectionHelp">
                                    <fmt:message key='openid.default.help'/>
                                </span>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField"><fmt:message key='openid.url'/>:<span class="required">*</span></td>
            <td>
                <input id="openIdUrl" name="openIdUrl" type="text" value="<%=openIdUrl%>"/>

                <div class="sectionHelp">
                    <fmt:message key='openid.url.help'/>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField"><fmt:message key='openid.user.id.location'/>:</td>
            <td>
                <label>
                    <input type="radio" value="0" name="open_id_user_id_location" <% if (!isOpenIdUserIdInClaims) { %>
                           checked="checked" <%}%> />
                    User ID found in 'claimed_id'
                </label>
                <label>
                    <input type="radio" value="1" name="open_id_user_id_location" <% if (isOpenIdUserIdInClaims) { %>
                           checked="checked" <%}%> />
                    User ID found among claims
                </label>

                <div class="sectionHelp">
                    <fmt:message key='openid.user.id.location.help'/>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField"><fmt:message key='query.param'/>:</td>
            <td>
                <%if (openidQueryParam != null) { %>
                <input id="openidQueryParam" name="openidQueryParam" type="text" value=<%=openidQueryParam%>>
                <% } else { %>
                <input id="openidQueryParam" name="openidQueryParam" type="text"/>
                <% } %>
                <div class="sectionHelp">
                    <fmt:message key='query.param.help'/>
                </div>
            </td>
        </tr>
    </table>
</div>

<h2 id="saml2_sso_head" class="sectionSeperator trigger active" style="background-color: beige;">
    <a href="#"><fmt:message key="saml2.web.sso.config"/></a>

    <div id="sampl2sso_enable_logo" class="enablelogo" style="float:right;padding-right: 5px;padding-top: 5px;"><img
            src="images/ok.png" alt="enable" width="16" height="16"></div>
</h2>
<div class="toggle_container sectionSub" style="margin-bottom:10px;" id="saml2SSOLinkRow">
    <table class="carbonFormTable">
        <tr>
            <td class="leftCol-med labelField">
                <label for="saml2SSOEnabled"><fmt:message key='saml2.sso.enabled'/></label>
            </td>
            <td>
                <div class="sectionCheckbox">
                    <input id="saml2SSOEnabled" name="saml2SSOEnabled" type="checkbox" <%=saml2SSOEnabledChecked%>
                           onclick="checkEnabled(this);"/>
                                <span style="display:inline-block" class="sectionHelp">
                                    <fmt:message key='saml2.sso.enabled.help'/>
                                </span>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField">
                <label for="saml2SSODefault"><fmt:message key='saml2.sso.default'/></label>
            </td>
            <td>
                <div class="sectionCheckbox">
                    <input id="saml2SSODefault" name="saml2SSODefault"
                           type="checkbox" <%=saml2SSODefaultChecked%> <%=saml2SSODefaultDisabled%>
                           onclick="checkDefault(this);"/>
                                <span style="display:inline-block" class="sectionHelp">
                                    <fmt:message key='saml2.sso.default.help'/>
                                </span>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField"><fmt:message key='idp.entity.id'/>:<span class="required">*</span></td>
            <td>
                <input id="idPEntityId" name="idPEntityId" type="text" value=<%=idPEntityId%>>

                <div class="sectionHelp">
                    <fmt:message key='idp.entity.id.help'/>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField"><fmt:message key='sp.entity.id'/>:<span class="required">*</span></td>
            <td>
                <input id="spEntityId" name="spEntityId" type="text" value=<%=spEntityId%>>

                <div class="sectionHelp">
                    <fmt:message key='sp.entity.id.help'/>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField"><fmt:message key='sso.url'/>:<span class="required">*</span></td>
            <td>
                <input id="ssoUrl" name="ssoUrl" type="text" value=<%=ssoUrl%>>

                <div class="sectionHelp">
                    <fmt:message key='sso.url.help'/>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField">
                <label for="authnRequestSigned"><fmt:message key='authn.request.signed'/></label>
            </td>
            <td>
                <div class="sectionCheckbox">
                    <input id="authnRequestSigned" name="authnRequestSigned"
                           type="checkbox" <%=authnRequestSignedChecked%>/>
                                <span style="display:inline-block" class="sectionHelp">
                                    <fmt:message key='authn.request.signed.help'/>
                                </span>
                </div>
            </td>
        </tr>

        <tr>
            <td class="leftCol-med labelField">
                <label for="enableAssersionEncryption"><fmt:message key='authn.enable.assertion.encryption'/></label>
            </td>
            <td>
                <div class="sectionCheckbox">
                    <input id="IsEnableAssetionEncription" name="IsEnableAssetionEncription"
                           type="checkbox" <%=enableAssertinEncriptionChecked%>/>
                                <span style="display:inline-block" class="sectionHelp">
                                    <fmt:message key='authn.enable.assertion.encryption.help'/>
                                </span>
                </div>
            </td>
        </tr>


        <tr>
            <td class="leftCol-med labelField">
                <label for="enableAssersionSigning"><fmt:message key='authn.enable.assertion.signing'/></label>
            </td>
            <td>
                <div class="sectionCheckbox">
                    <input id="isEnableAssertionSigning" name="isEnableAssertionSigning"
                           type="checkbox" <%=enableAssertionSigningChecked%>/>
                                <span style="display:inline-block" class="sectionHelp">
                                    <fmt:message key='authn.enable.assertion.signing.help'/>
                                </span>
                </div>
            </td>
        </tr>

        <tr>
            <td class="leftCol-med labelField">
                <label for="sloEnabled"><fmt:message key='logout.enabled'/></label>
            </td>
            <td>
                <div class="sectionCheckbox">
                    <input id="sloEnabled" name="sloEnabled" type="checkbox" <%=sloEnabledChecked%>/>
                                <span style="display:inline-block" class="sectionHelp">
                                    <fmt:message key='logout.enabled.help'/>
                                </span>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField"><fmt:message key='logout.url'/>:</td>
            <td>
                <input id="logoutUrl" name="logoutUrl" type="text" value=<%=logoutUrl%>>

                <div class="sectionHelp">
                    <fmt:message key='logout.url.help'/>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField">
                <label for="logoutRequestSigned"><fmt:message key='logout.request.signed'/></label>
            </td>
            <td>
                <div class="sectionCheckbox">
                    <input id="logoutRequestSigned" name="logoutRequestSigned"
                           type="checkbox" <%=logoutRequestSignedChecked%>/>
                                <span style="display:inline-block" class="sectionHelp">
                                    <fmt:message key='logout.request.signed.help'/>
                                </span>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField">
                <label for="authnResponseSigned"><fmt:message key='authn.response.signed'/></label>
            </td>
            <td>
                <div class="sectionCheckbox">
                    <input id="authnResponseSigned" name="authnResponseSigned"
                           type="checkbox" <%=authnResponseSignedChecked%>/>
                                <span style="display:inline-block" class="sectionHelp">
                                    <fmt:message key='authn.response.signed.help'/>
                                </span>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField"><fmt:message key='saml2.sso.user.id.location'/>:</td>
            <td>
                <label>
                    <input type="radio" value="0"
                           name="saml2_sso_user_id_location" <% if (!isSAMLSSOUserIdInClaims) { %>
                           checked="checked" <%}%> />
                    User ID found in 'Name Identifier'
                </label>
                <label>
                    <input type="radio" value="1" name="saml2_sso_user_id_location" <% if (isSAMLSSOUserIdInClaims) { %>
                           checked="checked" <%}%> />
                    User ID found among claims
                </label>

                <div class="sectionHelp">
                    <fmt:message key='saml2.sso.user.id.location.help'/>
                </div>
            </td>
        </tr>

        <tr>
            <td class="leftCol-med labelField"><fmt:message key='request.method'/>:</td>
            <td>
                <label>
                    <input type="radio" name="RequestMethod" value="redirect"
                           <% if(requestMethod != null && requestMethod.equals("redirect")){%>checked="checked"<%}%>/>HTTP-Redirect
                </label>
                <label><input type="radio" name="RequestMethod" value="post"
                              <% if(requestMethod != null && requestMethod.equals("post")){%>checked="checked"<%}%>/>HTTP-POST
                </label>
                <label><input type="radio" name="RequestMethod" value="as_request"
                              <% if(requestMethod != null && requestMethod.equals("as_request")){%>checked="checked"<%}%>/>As
                    Per Request
                </label>

                <div class="sectionHelp" style="margin-top: 5px">
                    <fmt:message key='request.method.help'/>
                </div>
            </td>
        </tr>

        <tr>
            <td class="leftCol-med labelField"><fmt:message key='query.param'/>:</td>
            <td>
                <%
                    if (samlQueryParam == null) {
                        samlQueryParam = "";
                    }
                %>

                <input id="samlQueryParam" name="samlQueryParam" type="text" value=<%=samlQueryParam%>>

                <div class="sectionHelp">
                    <fmt:message key='query.param.help'/>
                </div>
            </td>
        </tr>
    </table>
</div>

<h2 id="oauth2_head" class="sectionSeperator trigger active" style="background-color: beige;">
    <a href="#"><fmt:message key="oidc.config"/></a>

    <div id="oAuth2_enable_logo" class="enablelogo" style="float:right;padding-right: 5px;padding-top: 5px;"><img
            src="images/ok.png" alt="enable" width="16" height="16"></div>
</h2>
<div class="toggle_container sectionSub" style="margin-bottom:10px;" id="oauth2LinkRow">
    <table class="carbonFormTable">
        <tr>
            <td class="leftCol-med labelField">
                <label for="oidcEnabled"><fmt:message key='oidc.enabled'/></label>
            </td>
            <td>
                <div class="sectionCheckbox">
                    <input id="oidcEnabled" name="oidcEnabled" type="checkbox" <%=oidcEnabledChecked%>
                           onclick="checkEnabled(this);"/>
                                <span style="display:inline-block" class="sectionHelp">
                                    <fmt:message key='oidc.enabled.help'/>
                                </span>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField">
                <label for="oidcDefault"><fmt:message key='oidc.default'/></label>
            </td>
            <td>
                <div class="sectionCheckbox">
                    <input id="oidcDefault" name="oidcDefault"
                           type="checkbox" <%=oidcDefaultChecked%> <%=oidcDefaultDisabled%>
                           onclick="checkDefault(this);"/>
                                <span style="display:inline-block" class="sectionHelp">
                                    <fmt:message key='oidc.default.help'/>
                                </span>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField"><fmt:message key='authz.endpoint'/>:<span class="required">*</span></td>
            <td>
                <input id="authzUrl" name="authzUrl" type="text" value=<%=authzUrl%>>

                <div class="sectionHelp">
                    <fmt:message key='authz.endpoint.help'/>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField"><fmt:message key='token.endpoint'/>:<span class="required">*</span></td>
            <td>
                <input id="tokenUrl" name="tokenUrl" type="text" value=<%=tokenUrl%>>

                <div class="sectionHelp">
                    <fmt:message key='token.endpoint.help'/>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField"><fmt:message key='client.id'/>:<span class="required">*</span></td>
            <td>
                <input id="clientId" name="clientId" type="text" value=<%=clientId%>>

                <div class="sectionHelp">
                    <fmt:message key='client.id.help'/>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField"><fmt:message key='client.secret'/>:<span class="required">*</span></td>
            <td>
                <div id="showHideButtonDivIdOauth" style="border:1px solid rgb(88, 105, 125);" class="leftCol-med">
                    <input id="clientSecret" name="clientSecret" type="password" value="<%=clientSecret%>"
                           style="  outline: none; border: none; min-width: 175px; max-width: 180px;"/>
	                            <span id="showHideButtonIdOauth" style=" float: right; padding-right: 5px;">
	                        		<a style="margin-top: 5px;" class="showHideBtn"
                                       onclick="showHidePassword(this, 'clientSecret')">Show</a>
	                       		</span>
                </div>
                <div class="sectionHelp">
                    <fmt:message key='client.secret.help'/>
                </div>
            </td>
        </tr>

        <tr>
            <td class="leftCol-med labelField"><fmt:message key='oidc.user.id.location'/>:</td>
            <td>
                <label>
                    <input type="radio" value="0" name="oidc_user_id_location" <% if (!isOIDCUserIdInClaims) { %>
                           checked="checked" <%}%> />
                    User ID found in 'sub' attribute
                </label>
                <label>
                    <input type="radio" value="1" name="oidc_user_id_location" <% if (isOIDCUserIdInClaims) { %>
                           checked="checked" <%}%> />
                    User ID found among claims
                </label>

                <div class="sectionHelp">
                    <fmt:message key='oidc.user.id.location.help'/>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField"><fmt:message key='query.param'/>:</td>
            <td>
                <input id="oidcQueryParam" name="oidcQueryParam" type="text" value=<%=oidcQueryParam%>>

                <div class="sectionHelp">
                    <fmt:message key='query.param.help'/>
                </div>
            </td>
        </tr>
    </table>
</div>

<h2 id="passive_sts_head" class="sectionSeperator trigger active" style="background-color: beige;">
    <a href="#"><fmt:message key="passive.sts.config"/></a>

    <div id="wsfederation_enable_logo" class="enablelogo" style="float:right;padding-right: 5px;padding-top: 5px;"><img
            src="images/ok.png" alt="enable" width="16" height="16"></div>
</h2>
<div class="toggle_container sectionSub" style="margin-bottom:10px;" id="passiveSTSLinkRow">
    <table class="carbonFormTable">
        <tr>
            <td class="leftCol-med labelField">
                <label for="passiveSTSEnabled"><fmt:message key='passive.sts.enabled'/></label>
            </td>
            <td>
                <div class="sectionCheckbox">
                    <input id="passiveSTSEnabled" name="passiveSTSEnabled" type="checkbox" <%=passiveSTSEnabledChecked%>
                           onclick="checkEnabled(this);"/>
                                <span style="display:inline-block" class="sectionHelp">
                                    <fmt:message key='passive.sts.enabled.help'/>
                                </span>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField">
                <label for="passiveSTSDefault"><fmt:message key='passive.sts.default'/></label>
            </td>
            <td>
                <div class="sectionCheckbox">
                    <input id="passiveSTSDefault" name="passiveSTSDefault"
                           type="checkbox" <%=passiveSTSDefaultChecked%> <%=passiveSTSDefaultDisabled%>
                           onclick="checkDefault(this);"/>
                                <span style="display:inline-block" class="sectionHelp">
                                    <fmt:message key='passive.sts.default.help'/>
                                </span>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField"><fmt:message key='passive.sts.realm'/>:<span class="required">*</span>
            </td>
            <td>
                <input id="passiveSTSRealm" name="passiveSTSRealm" type="text" value="<%=passiveSTSRealm%>"/>

                <div class="sectionHelp">
                    <fmt:message key='passive.sts.realm.help'/>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField"><fmt:message key='passive.sts.url'/>:<span class="required">*</span></td>
            <td>
                <input id="passiveSTSUrl" name="passiveSTSUrl" type="text" value="<%=passiveSTSUrl%>"/>

                <div class="sectionHelp">
                    <fmt:message key='passive.sts.url.help'/>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField"><fmt:message key='passive.sts.user.id.location'/>:</td>
            <td>
                <label>
                    <input type="radio" value="0"
                           name="passive_sts_user_id_location" <% if (!isPassiveSTSUserIdInClaims) { %>
                           checked="checked" <%}%>/>
                    User ID found in 'Name Identifier'
                </label>
                <label>
                    <input type="radio" value="1"
                           name="passive_sts_user_id_location" <% if (isPassiveSTSUserIdInClaims) { %>
                           checked="checked" <%}%>/>
                    User ID found among claims
                </label>

                <div class="sectionHelp">
                    <fmt:message key='passive.sts.user.id.location.help'/>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField"><fmt:message key='query.param'/>:</td>
            <td>
                <input id="passiveSTSQueryParam" name="passiveSTSQueryParam" type="text"
                       value=<%=passiveSTSQueryParam%>>

                <div class="sectionHelp">
                    <fmt:message key='query.param.help'/>
                </div>
            </td>
        </tr>
    </table>
</div>

<h2 id="fb_auth_head" class="sectionSeperator trigger active" style="background-color: beige;">
    <a href="#"><fmt:message key="fbauth.config"/></a>

    <div id="fecebook_enable_logo" class="enablelogo" style="float:right;padding-right: 5px;padding-top: 5px;"><img
            src="images/ok.png" alt="enable" width="16" height="16"></div>
</h2>
<div class="toggle_container sectionSub" style="margin-bottom:10px;" id="fbAuthLinkRow">
    <table class="carbonFormTable">
        <tr>
            <td class="leftCol-med labelField">
                <label for="fbAuthEnabled"><fmt:message key='fbauth.enabled'/></label>
            </td>
            <td>
                <div class="sectionCheckbox">
                    <input id="fbAuthEnabled" name="fbAuthEnabled" type="checkbox" <%=fbAuthEnabledChecked%>
                           onclick="checkEnabled(this);"/>
                                <span style="display:inline-block" class="sectionHelp">
                                    <fmt:message key='fbauth.enabled.help'/>
                                </span>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField">
                <label for="fbAuthDefault"><fmt:message key='fbauth.default'/></label>
            </td>
            <td>
                <div class="sectionCheckbox">
                    <input id="fbAuthDefault" name="fbAuthDefault"
                           type="checkbox" <%=fbAuthDefaultChecked%> <%=fbAuthDefaultDisabled%>
                           onclick="checkDefault(this);"/>
                                <span style="display:inline-block" class="sectionHelp">
                                    <fmt:message key='fbauth.default.help'/>
                                </span>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField"><fmt:message key='client.id'/>:<span class="required">*</span></td>
            <td>
                <input id="fbClientId" name="fbClientId" type="text" value="<%=fbClientId%>"/>

                <div class="sectionHelp">
                    <fmt:message key='fbauth.client.id.help'/>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField"><fmt:message key='client.secret'/>:<span class="required">*</span></td>
            <td>
                <div id="showHideButtonDivId" style="border:1px solid rgb(88, 105, 125);" class="leftCol-med">
                    <input id="fbClientSecret" name="fbClientSecret" type="password" value="<%=fbClientSecret%>"
                           style="  outline: none; border: none; min-width: 175px; max-width: 180px;"/>
       							<span id="showHideButtonId" style=" float: right; padding-right: 5px;"> 
       								<a style="margin-top: 5px;" class="showHideBtn"
                                       onclick="showHidePassword(this, 'fbClientSecret')">Show</a> 
       							</span>
                </div>

                <div class="sectionHelp"><fmt:message key='fbauth.client.secret.help'/></div>
            </td>

        </tr>
        <tr>
            <td class="leftCol-med labelField"><fmt:message key='fbauth.scope'/>:</td>
            <td>
                <input id="fbScope" name="fbScope" type="text"
                       value="<%=fbScope%>"/>

                <div class="sectionHelp">
                    <fmt:message key='fbauth.scope.help'/>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField"><fmt:message key='fbauth.user.information.fields'/>:</td>
            <td>
                <input id="fbUserInfoFields" name="fbUserInfoFields" type="text"
                       value="<%=fbUserInfoFields%>"/>

                <div class="sectionHelp">
                    <fmt:message key='fbauth.user.information.fields.help'/>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField">Facebook Authentication Endpoint:<span
                    class="required">*</span></td>
            <td><input class="text-box-big" id="fbAuthnEndpoint"
                       name="fbAuthnEndpoint" type="text" value=<%=fbAuthnEndpoint%>></td>
        </tr>
        <tr>
            <td class="leftCol-med labelField">Facebook OAuth2 Token Endpoint:<span
                    class="required">*</span></td>
            <td><input class="text-box-big" id="fbOauth2TokenEndpoint"
                       name="fbOauth2TokenEndpoint" type="text" value=<%=fbOauth2TokenEndpoint%>></td>
        </tr>
        <tr>
            <td class="leftCol-med labelField">Facebook User Information Endpoint:<span
                    class="required">*</span></td>
            <td><input class="text-box-big" id="fbUserInfoEndpoint"
                       name="fbUserInfoEndpoint" type="text" value=<%=fbUserInfoEndpoint%>></td>
        </tr>
    </table>
</div>

<%

    if (allFedAuthConfigs != null && allFedAuthConfigs.size() > 0) {

        for (Map.Entry<String, FederatedAuthenticatorConfig> entry : allFedAuthConfigs.entrySet()) {
            FederatedAuthenticatorConfig fedConfig = entry.getValue();
            if (fedConfig != null) {
                boolean isEnabled = fedConfig.getEnabled();

                boolean isDefault = false;

                if (identityProvider != null && identityProvider.getDefaultAuthenticatorConfig() != null && identityProvider.getDefaultAuthenticatorConfig().getDisplayName() != null
                        && identityProvider.getDefaultAuthenticatorConfig().getName().equals(fedConfig.getName())) {
                    isDefault = true;
                }


                String valueChecked = "";
                String valueDefaultDisabled = "";

                String enableChecked = "";
                String enableDefaultDisabled = "";

                if (isDefault) {
                    valueChecked = "checked=\'checked\'";
                    valueDefaultDisabled = "disabled=\'disabled\'";
                }

                if (isEnabled) {
                    enableChecked = "checked=\'checked\'";
                    enableDefaultDisabled = "disabled=\'disabled\'";
                }

                if (fedConfig.getDisplayName() != null && fedConfig.getDisplayName().trim().length() > 0) {

%>

<h2 id="custom_auth_head_"<%=fedConfig.getDisplayName() %> class="sectionSeperator trigger active"
    style="background-color: beige;">
    <a href="#" style="text-transform:capitalize;"><%=fedConfig.getDisplayName() %> Configuration</a>
    <% if (isEnabled) { %>
    <div id="custom_auth_head_enable_logo_<%=fedConfig.getName()%>" class="enablelogo"
         style="float:right;padding-right: 5px;padding-top: 5px;"><img src="images/ok.png" alt="enable" width="16"
                                                                       height="16"></div>
    <%} else {%>
    <div id="custom_auth_head_enable_logo_<%=fedConfig.getName()%>" class="enablelogo"
         style="float:right;padding-right: 5px;padding-top: 5px; display: none"><img src="images/ok.png" alt="enable"
                                                                                     width="16" height="16"></div>
    <%}%>
</h2>
<div class="toggle_container sectionSub" style="margin-bottom:10px;display: none;"
     id="custom_auth_<%=fedConfig.getName()%>">
    <table class="carbonFormTable">
        <tr>
            <td class="leftCol-med labelField">
                <input type="hidden" name="custom_auth_name" value=<%=fedConfig.getName()%>>
                <input type="hidden" name="<%=fedConfig.getName()%>_DisplayName" value=<%=fedConfig.getDisplayName()%>>

                <label for="<%=fedConfig.getName()%>Enabled">Enable</label>
            </td>
            <td>
                <div class="sectionCheckbox">
                    <input id="<%=fedConfig.getName()%>_Enabled" name="<%=fedConfig.getName()%>_Enabled"
                           type="checkbox" <%=enableChecked%>
                           onclick="checkEnabled(this); checkEnabledLogo(this, '<%=fedConfig.getName()%>')"/>
                                <span style="display:inline-block" class="sectionHelp">Specifies if custom authenticator is enabled for this Identity Provider
                                </span>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField">
                <label for="<%=fedConfig.getName()%>_Default">Default</label>
            </td>
            <td>
                <div class="sectionCheckbox">
                    <input id="<%=fedConfig.getName()%>_Default" name="<%=fedConfig.getName()%>_Default"
                           type="checkbox" <%=valueChecked%> <%=valueDefaultDisabled%> onclick="checkDefault(this);"/>
                                 <span style="display:inline-block" class="sectionHelp">Specifies if custom authenticator is the default
                                </span>
                </div>
            </td>
        </tr>

        <% Property[] properties = fedConfig.getProperties();
            if (properties != null && properties.length > 0) {
                for (Property prop : properties) {
                    if (prop != null && prop.getDisplayName() != null) {
        %>

        <tr>
            <%if (prop.getRequired()) { %>
            <td class="leftCol-med labelField"><%=prop.getDisplayName()%>:<span class="required">*</span></td>
            <% } else { %>
            <td class="leftCol-med labelField"><%=prop.getDisplayName()%>:</td>
            <%} %>
            <td>
                <% if (prop.getConfidential()) { %>

                <% if (prop.getValue() != null) { %>
                <div id="showHideButtonDivId" style="border:1px solid rgb(88, 105, 125);" class="leftCol-med">
                    <input id="cust_auth_prop_<%=fedConfig.getName()%>#<%=prop.getName()%>"
                           name="cust_auth_prop_<%=fedConfig.getName()%>#<%=prop.getName()%>" type="password"
                           value="<%=prop.getValue()%>"
                           style="  outline: none; border: none; min-width: 175px; max-width: 180px;"/>
       												<span id="showHideButtonId"
                                                          style=" float: right; padding-right: 5px;"> 
       													<a style="margin-top: 5px;" class="showHideBtn"
                                                           onclick="showHidePassword(this, 'cust_auth_prop_<%=fedConfig.getName()%>#<%=prop.getName()%>')">Show</a> 
       												</span>
                </div>
                <% } else { %>

                <div id="showHideButtonDivId" style="border:1px solid rgb(88, 105, 125);" class="leftCol-med">
                    <input id="cust_auth_prop_<%=fedConfig.getName()%>#<%=prop.getName()%>"
                           name="cust_auth_prop_<%=fedConfig.getName()%>#<%=prop.getName()%>" type="password"
                           style="  outline: none; border: none; min-width: 175px; max-width: 180px;"/>
       												<span id="showHideButtonId"
                                                          style=" float: right; padding-right: 5px;"> 
       													<a style="margin-top: 5px;" class="showHideBtn"
                                                           onclick="showHidePassword(this, 'cust_auth_prop_<%=fedConfig.getName()%>#<%=prop.getName()%>')">Show</a> 
       												</span>
                </div>

                <% } %>

                <% } else { %>

                <% if (prop.getValue() != null) { %>
                <input id="cust_auth_prop_<%=fedConfig.getName()%>#<%=prop.getName()%>"
                       name="cust_auth_prop_<%=fedConfig.getName()%>#<%=prop.getName()%>" type="text"
                       value="<%=prop.getValue()%>"/>
                <% } else { %>
                <input id="cust_auth_prop_<%=fedConfig.getName()%>#<%=prop.getName()%>"
                       name="cust_auth_prop_<%=fedConfig.getName()%>#<%=prop.getName()%>" type="text">
                <% } %>

                <% } %>

                <%
                    if (prop.getDescription() != null) { %>
                <div class="sectionHelp"><%=prop.getDescription()%>
                </div>
                <%} %>
            </td>
        </tr>
        <%
                    }
                }
            }
        %>

    </table>
</div>

<%
                }
            }
        }
    }
%>

</div>

<h2 id="in_bound_provisioning_head" class="sectionSeperator trigger active">
    <a href="#"><fmt:message key="in.bound.provisioning.config"/></a>
</h2>

<div class="toggle_container sectionSub" style="margin-bottom:10px;" id="inBoundProvisioning">
    <table>
        <tr>
            <td>
                <label style="display:block">
                    <input type="radio" id="provision_disabled" name="provisioning"
                           value="provision_disabled" <% if (!isProvisioningEnabled) { %> checked="checked" <% } %> />
                    No provisioning
                </label>

                <div>
                    <label>
                        <input type="radio" id="provision_static" name="provisioning"
                               value="provision_static" <% if (isProvisioningEnabled && provisioningUserStoreId != null) { %>
                               checked="checked" <% } %>/>
                        Always provision to User Store Domain
                    </label>
                    <select id="provision_static_dropdown"
                            name="provision_static_dropdown" <%=provisionStaticDropdownDisabled%>>
                        <%
                            if (userStoreDomains != null && userStoreDomains.length > 0) {
                                for (String userStoreDomain : userStoreDomains) {
                                    if (provisioningUserStoreId != null && userStoreDomain.equals(provisioningUserStoreId)) {
                        %>
                        <option selected="selected"><%=userStoreDomain%>
                        </option>
                        <%
                        } else {
                        %>
                        <option><%=userStoreDomain%>
                        </option>
                        <%
                                    }
                                }
                            }
                        %>
                    </select>

                </div>

                <div class="sectionHelp">
                    <fmt:message key='provisioning.enabled.help'/>
                </div>
            </td>
        </tr>
    </table>
</div>


<!-- Outbound Provisioning UI -->
<h2 id="out_bound_provisioning_head" class="sectionSeperator trigger active">
    <a href="#"><fmt:message key="out.bound.provisioning.config"/></a>
</h2>


<div class="toggle_container sectionSub"
     style="margin-bottom: 10px; display: none;" id="outBoundProv">

<!-- Google Connector -->
<h2 id="google_prov_head" class="sectionSeperator trigger active"
    style="background-color: beige;">
    <a href="#"><fmt:message key="google.provisioning.connector"/></a>

    <div id="google_enable_logo" class="enablelogo" style="float:right;padding-right: 5px;padding-top: 5px;"><img
            src="images/ok.png" alt="enable" width="16" height="16"></div>
</h2>
<div class="toggle_container sectionSub"
     style="margin-bottom: 10px; display: none;" id="googleProvRow">
    <table class="carbonFormTable">
        <tr>
            <td class="leftCol-med labelField"><label
                    for="googleProvEnabled"><fmt:message
                    key='google.provisioning.enabled'/>:</label></td>
            <td>
                <div class="sectionCheckbox">
                    <!-- -->
                    <input id="googleProvEnabled" name="googleProvEnabled"
                           type="checkbox" <%=googleProvEnabledChecked%>
                           onclick="checkProvEnabled(this);"/> <span
                        style="display: inline-block" class="sectionHelp"> <fmt:message
                        key='google.provisioning.enabled.help'/>
										</span>
                </div>
            </td>
        </tr>
        <tr style="display:none;">
            <td class="leftCol-med labelField"><label
                    for="googleProvDefault"><fmt:message
                    key='google.provisioning.default'/>:</label></td>
            <td>
                <div class="sectionCheckbox">
                    <!-- -->
                    <input id="googleProvDefault" name="googleProvDefault"
                           type="checkbox" <%=googleProvDefaultChecked%>
                            <%=googleProvDefaultDisabled%>
                           onclick="checkProvDefault(this);"/> <span
                        style="display: inline-block" class="sectionHelp"> <fmt:message
                        key='google.provisioning.default.help'/>
										</span>
                </div>
            </td>
        </tr>

        <tr>
            <td class="leftCol-med labelField"><fmt:message
                    key='google.provisioning.domain.name'/>:<span class="required">*</span></td>
            <td><input id="google_prov_domain_name"
                       name="google_prov_domain_name" type="text"
                       value="<%=googleDomainName%>"/>

                <div class="sectionHelp">
                    <fmt:message key='google.provisioning.domain.name.help'/>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField"><fmt:message
                    key='google.provisioning.attribute.primary.email'/>:<span class="required">*</span></td>
            <td>
                <div>
                    <select id="google_prov_email_claim_dropdown"
                            name="google_prov_email_claim_dropdown">
                    </select>
                    <!--a id="claimMappingAddLink" class="icon-link" style="background-image: url(images/add.gif);"><fmt:message key='button.add.claim.mapping' /></a-->
                </div>
                <div class="sectionHelp">
                    <fmt:message
                            key='google.provisioning.attribute.primary.email.help'/>
                </div>
            </td>
        </tr>

        <tr>
            <td class="leftCol-med labelField"><fmt:message
                    key='google.provisioning.attribute.given.name'/>:<span class="required">*</span></td>
            <td>
                <div>
                    <label> <!-- --> Pick given name from Claim :
                    </label> <select id="google_prov_givenname_claim_dropdown"
                                     name="google_prov_givenname_claim_dropdown">
                </select>
                </div>
                <div style=" display: none; ">
                    <label> Given name default value : </label> <input
                        id="google_prov_givenname" name="google_prov_givenname"
                        type="text" value="<%=googleGivenNameDefaultValue%>"/>
                </div>
                <div class="sectionHelp">
                    <fmt:message
                            key='google.provisioning.attribute.given.name.help'/>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField"><fmt:message
                    key='google.provisioning.attribute.family.name'/>:<span class="required">*</span></td>
            <td>
                <div>
                    <label> Pick family name from Claim : </label> <select
                        id="google_prov_familyname_claim_dropdown"
                        name="google_prov_familyname_claim_dropdown">
                </select>
                </div>
                <div style=" display: none;">
                    <label> Family name default value : </label> <input
                        id="google_prov_familyname" name="google_prov_familyname"
                        type="text" value="<%=googleFamilyNameDefaultValue%>"/>
                </div>
                <div class="sectionHelp">
                    <fmt:message
                            key='google.provisioning.attribute.family.name.help'/>
                </div>
            </td>
        </tr>

        <tr>
            <td class="leftCol-med labelField"><fmt:message
                    key='google.provisioning.service.accont.email'/>:<span class="required">*</span></td>
            <td>
                <div>
                    <input id="google_prov_service_acc_email"
                           name="google_prov_service_acc_email" type="text"
                           value="<%=googleProvServiceAccEmail%>"/>
                </div>
                <div class="sectionHelp">
                    <fmt:message
                            key='google.provisioning.service.accont.email.help'/>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField"><fmt:message
                    key='google.provisioning.service.account.private.key'/>:
            </td>
            <td><span><input id="google_prov_private_key"
                             name="google_prov_private_key" type="file"/>
									<% if (googleProvPrivateKeyData != null) { %>
                                         <img src="images/key.png" alt="key" width="14" height="14"
                                              style=" padding-right: 5px; "><label>Private Key attached</label>
									<% } %></span>

                <div class="sectionHelp">
                    <fmt:message
                            key='google.provisioning.service.account.private.key.help'/>
                </div>
                <div id="google_prov_privatekey_div">

                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField"><fmt:message
                    key='google.provisioning.admin.email'/>:<span class="required">*</span></td>
            <td>
                <div>
                    <input id="google_prov_admin_email"
                           name="google_prov_admin_email" type="text"
                           value="<%=googleProvAdminEmail%>"/>
                </div>
                <div class="sectionHelp">
                    <fmt:message key='google.provisioning.admin.email.help'/>
                </div>
            </td>
        </tr>
        <tr>
            <td class="leftCol-med labelField"><fmt:message
                    key='google.provisioning.application.name'/>:<span class="required">*</span></td>
            <td>
                <div>
                    <input id="google_prov_application_name"
                           name="google_prov_application_name" type="text"
                           value="<%=googleProvApplicationName%>"/>
                </div>
                <div class="sectionHelp">
                    <fmt:message key='google.provisioning.application.name.help'/>
                </div>
            </td>
        </tr>

        <tr>
            <td class="leftCol-med labelField"><fmt:message
                    key='google.provisioning.pattern'/>:
            </td>
            <td>
                <div>
                    <input id="google_prov_pattern"
                           name="google_prov_pattern" type="text"
                           value="<%=googleProvPattern%>"/>
                </div>
                <div class="sectionHelp">
                    <fmt:message key='google_prov_pattern.help'/>
                </div>
            </td>
        </tr>

        <tr>
            <td class="leftCol-med labelField"><fmt:message
                    key='google.provisioning.separator'/>:
            </td>
            <td>
                <div>
                    <input id="google_prov_separator"
                           name="google_prov_separator" type="text"
                           value="<%=googleProvisioningSeparator%>"/>
                </div>
                <div class="sectionHelp">
                    <fmt:message key='google.provisioning.separator.help'/>
                </div>
            </td>
        </tr>

    </table>
</div>

<h2 id="sf_prov_head" class="sectionSeperator trigger active"
    style="background-color: beige;">
    <a href="#"><fmt:message key="sf.provisioning.connector"/></a>

    <div id="sf_enable_logo" class="enablelogo" style="float:right;padding-right: 5px;padding-top: 5px;"><img
            src="images/ok.png" alt="enable" width="16" height="16"></div>
</h2>
<div class="toggle_container sectionSub"
     style="margin-bottom: 10px; display: none;" id="sfProvRow">

    <table class="carbonFormTable">
        <tr>
            <td class="leftCol-med labelField"><label
                    for="sfProvEnabled"><fmt:message
                    key='sf.provisioning.enabled'/>:</label></td>
            <td>
                <div class="sectionCheckbox">
                    <!-- -->
                    <input id="sfProvEnabled" name="sfProvEnabled"
                           type="checkbox" <%=sfProvEnabledChecked%>
                           onclick="checkProvEnabled(this);"/> <span
                        style="display: inline-block" class="sectionHelp"> <fmt:message
                        key='sf.provisioning.enabled.help'/>
                                        </span>
                </div>
            </td>
        </tr>
        <tr style="display:none;">
            <td class="leftCol-med labelField"><label
                    for="sfProvDefault"><fmt:message
                    key='sf.provisioning.default'/>:</label></td>
            <td>
                <div class="sectionCheckbox">
                    <!-- -->
                    <input id="sfProvDefault" name="sfProvDefault"
                           type="checkbox" <%=sfProvDefaultChecked%>
                            <%=sfProvDefaultDisabled%>
                           onclick="checkProvDefault(this);"/> <span
                        style="display: inline-block" class="sectionHelp"> <fmt:message
                        key='sf.provisioning.default.help'/>
                                        </span>
                </div>
            </td>
        </tr>

        <tr>
            <td class="leftCol-med labelField">API version:<span
                    class="required">*</span></td>
            <td><input class="text-box-big" id="sf-api-version"
                       name="sf-api-version" type="text" value=<%=sfApiVersion %>></td>
        </tr>
        <tr>
            <td class="leftCol-med labelField">Domain Name:<span
                    class="required">*</span></td>
            <td><input class="text-box-big" id="sf-domain-name"
                       name="sf-domain-name" type="text" value=<%=sfDomainName %>></td>
        </tr>
        <tr>
            <td class="leftCol-med labelField">Client ID:<span
                    class="required">*</span></td>
            <td><input class="text-box-big" id="sf-clientid"
                       name="sf-clientid" type="text" value=<%=sfClientId %>></td>
        </tr>
        <tr>
            <td class="leftCol-med labelField">Client Secret:<span
                    class="required">*</span></td>
            <td><input class="text-box-big" id="sf-client-secret"
                       name="sf-client-secret" type="password" value=<%=sfClientSecret %>></td>
        </tr>
        <tr>
            <td class="leftCol-med labelField">Username:<span
                    class="required">*</span></td>
            <td><input class="text-box-big" id="sf-username"
                       name="sf-username" type="text" value=<%=sfUserName %>></td>
        </tr>
        <tr>
            <td class="leftCol-med labelField">Password:<span
                    class="required">*</span></td>
            <td><input class="text-box-big" id="sf-password"
                       name="sf-password" type="password" value=<%=sfPassword %>></td>
        </tr>
        <tr>
            <td class="leftCol-med labelField">OAuth2 Token Endpoint:<span
                    class="required">*</span></td>
            <td><input class="text-box-big" id="sf-token-endpoint"
                       name="sf-token-endpoint" type="text" value=<%=sfOauth2TokenEndpoint%>></td>
        </tr>
        <tr>
            <td class="leftCol-med labelField">Provisioning Pattern:</td>
            <td><input class="text-box-big" id="sf-prov-pattern"
                       name="sf-prov-pattern" type="text" value=<%=sfProvPattern%>></td>
        </tr>

        <tr>
            <td class="leftCol-med labelField">Provisioning Separator:</td>
            <td><input class="text-box-big" id="sf-prov-separator"
                       name="sf-prov-separator" type="text" value=<%=sfProvSeparator%>></td>
        </tr>

        <tr>
            <td class="leftCol-med labelField">Provisioning Domain:</td>
            <td><input class="text-box-big" id="sf-prov-domainName"
                       name="sf-prov-domainName" type="text" value=<%=sfProvDomainName%>></td>
        </tr>

    </table>

</div>

<h2 id="scim_prov_head" class="sectionSeperator trigger active"
    style="background-color: beige;">
    <a href="#"><fmt:message key="scim.provisioning.connector"/></a>

    <div id="scim_enable_logo" class="enablelogo" style="float:right;padding-right: 5px;padding-top: 5px;"><img
            src="images/ok.png" alt="enable" width="16" height="16"></div>

</h2>
<div class="toggle_container sectionSub"
     style="margin-bottom: 10px; display: none;" id="scimProvRow">

    <table class="carbonFormTable">
        <tr>
            <td class="leftCol-med labelField"><label
                    for="scimProvEnabled"><fmt:message
                    key='scim.provisioning.enabled'/>:</label></td>
            <td>
                <div class="sectionCheckbox">
                    <!-- -->
                    <input id="scimProvEnabled" name="scimProvEnabled"
                           type="checkbox" <%=scimProvEnabledChecked%>
                           onclick="checkProvEnabled(this);"/> <span
                        style="display: inline-block" class="sectionHelp"> <fmt:message
                        key='scim.provisioning.enabled.help'/>
                                        </span>
                </div>
            </td>
        </tr>
        <tr style="display:none;">
            <td class="leftCol-med labelField"><label
                    for="scimProvDefault"><fmt:message
                    key='scim.provisioning.default'/>:</label></td>
            <td>
                <div class="sectionCheckbox">
                    <!-- -->
                    <input id="scimProvDefault" name="scimProvDefault"
                           type="checkbox" <%=scimProvDefaultChecked%>
                            <%=scimProvDefaultDisabled%>
                           onclick="checkProvDefault(this);"/> <span
                        style="display: inline-block" class="sectionHelp"> <fmt:message
                        key='scim.provisioning.default.help'/>
                                        </span>
                </div>
            </td>
        </tr>

        <tr>
            <td class="leftCol-med labelField">Username:<span
                    class="required">*</span></td>
            <td><input class="text-box-big" id="scim-username"
                       name="scim-username" type="text" value=<%=scimUserName %>></td>
        </tr>
        <tr>
            <td class="leftCol-med labelField">Password:<span
                    class="required">*</span></td>
            <td><input class="text-box-big" id="scim-password"
                       name="scim-password" type="password" value=<%=scimPassword %>></td>
        </tr>
        <tr>
            <td class="leftCol-med labelField">User Endpoint:<span
                    class="required">*</span></td>
            <td><input class="text-box-big" id="scim-user-ep"
                       name="scim-user-ep" type="text" value=<%=scimUserEp %>></td>
        </tr>
        <tr>
            <td class="leftCol-med labelField">Group Endpoint:</td>
            <td><input class="text-box-big" id="scim-group-ep"
                       name="scim-group-ep" type="text" value=<%=scimGroupEp %>></td>
        </tr>
        <tr>
            <td class="leftCol-med labelField">User Store Domain:</td>
            <td><input class="text-box-big" id="scim-user-store-domain" name="scim-user-store-domain" type="text"
                       value=<%=scimUserStoreDomain%>></td>
        </tr>
    </table>

</div>

<h2 id="spml_prov_head" class="sectionSeperator trigger active"
    style="background-color: beige;">
    <a href="#"><fmt:message key="spml.provisioning.connector"/></a>

    <div id="spml_enable_logo" class="enablelogo" style="float:right;padding-right: 5px;padding-top: 5px;"><img
            src="images/ok.png" alt="enable" width="16" height="16"></div>

</h2>
<div class="toggle_container sectionSub"
     style="margin-bottom: 10px; display: none;" id="spmlProvRow">

    <table class="carbonFormTable">

        <tr>
            <td class="leftCol-med labelField"><label
                    for="spmlProvEnabled"><fmt:message
                    key='spml.provisioning.enabled'/>:</label></td>
            <td>
                <div class="sectionCheckbox">
                    <!-- -->
                    <input id="spmlProvEnabled" name="spmlProvEnabled"
                           type="checkbox" <%=spmlProvEnabledChecked%>
                           onclick="checkProvEnabled(this);"/> <span
                        style="display: inline-block" class="sectionHelp"> <fmt:message
                        key='spml.provisioning.enabled.help'/>
                                        </span>
                </div>
            </td>
        </tr>
        <tr style="display:none;">
            <td class="leftCol-med labelField"><label
                    for="spmlProvDefault"><fmt:message
                    key='spml.provisioning.default'/>:</label></td>
            <td>
                <div class="sectionCheckbox">
                    <!-- -->
                    <input id="spmlProvDefault" name="spmlProvDefault"
                           type="checkbox" <%=spmlProvDefaultChecked%>
                            <%=spmlProvDefaultDisabled%>
                           onclick="checkProvDefault(this);"/> <span
                        style="display: inline-block" class="sectionHelp"> <fmt:message
                        key='spml.provisioning.default.help'/>
                                        </span>
                </div>
            </td>
        </tr>

        <tr>
            <td class="leftCol-med labelField">Username:</td>
            <td><input class="text-box-big" id="spml-username"
                       name="spml-username" type="text" value=<%=spmlUserName %>></td>
        </tr>
        <tr>
            <td class="leftCol-med labelField">Password:</td>
            <td><input class="text-box-big" id="spml-password"
                       name="spml-password" type="password" value=<%=spmlPassword %>></td>
        </tr>
        <tr>
            <td class="leftCol-med labelField">SPML Endpoint:<span
                    class="required">*</span></td>
            <td><input class="text-box-big" id="spml-ep" name="spml-ep"
                       type="text" value=<%=spmlEndpoint %>></td>
        </tr>

        <tr>
            <td class="leftCol-med labelField">SPML ObjectClass:<span
                    class="required">*</span></td>
            <td><input class="text-box-big" id="spml-oc" name="spml-oc"
                       type="text" value=<%=spmlObjectClass %>></td>
        </tr>

    </table>
</div>

<%

    if (customProvisioningConnectors != null && customProvisioningConnectors.size() > 0) {

        for (Map.Entry<String, ProvisioningConnectorConfig> entry : customProvisioningConnectors.entrySet()) {
            ProvisioningConnectorConfig fedConfig = entry.getValue();
            if (fedConfig != null) {
                boolean isEnabled = fedConfig.getEnabled();


                String enableChecked = "";

                if (isEnabled) {
                    enableChecked = "checked=\'checked\'";
                }

                if (fedConfig.getName() != null && fedConfig.getName().trim().length() > 0) {

%>

<h2 id="custom_pro_head_"<%=fedConfig.getName() %> class="sectionSeperator trigger active"
    style="background-color: beige;">
    <a href="#" style="text-transform:capitalize;"><%=fedConfig.getName()%> Provisioning Configuration</a>
    <% if (isEnabled) { %>
    <div id="custom_pro_head_enable_logo_<%=fedConfig.getName()%>" class="enablelogo"
         style="float:right;padding-right: 5px;padding-top: 5px;"><img src="images/ok.png" alt="enable" width="16"
                                                                       height="16"></div>
    <%} else {%>
    <div id="custom_pro_head_enable_logo_<%=fedConfig.getName()%>" class="enablelogo"
         style="float:right;padding-right: 5px;padding-top: 5px; display: none"><img src="images/ok.png" alt="enable"
                                                                                     width="16" height="16"></div>
    <%}%>
</h2>
<div class="toggle_container sectionSub" style="margin-bottom:10px;display: none;"
     id="custom_pro_<%=fedConfig.getName()%>">
    <table class="carbonFormTable">
        <tr>
            <td class="leftCol-med labelField">
                <input type="hidden" name="custom_pro_name" value=<%=fedConfig.getName()%>>

                <label for="<%=fedConfig.getName()%>Enabled">Enable</label>
            </td>
            <td>
                <div class="sectionCheckbox">
                    <input id="<%=fedConfig.getName()%>_PEnabled" name="<%=fedConfig.getName()%>_PEnabled"
                           type="checkbox" <%=enableChecked%>
                           onclick="checkEnabledLogo(this, '<%=fedConfig.getName()%>')"/>
                                <span style="display:inline-block" class="sectionHelp">Specifies if custom provisioning connector is enabled for this Identity Provider
                                </span>
                </div>
            </td>
        </tr>


        <%
            Property[] properties = fedConfig.getProvisioningProperties();
            if (properties != null && properties.length > 0) {
                for (Property prop : properties) {
                    if (prop != null && prop.getDisplayName() != null) {
        %>

        <tr>
            <%if (prop.getRequired()) { %>
            <td class="leftCol-med labelField"><%=prop.getDisplayName()%>:<span class="required">*</span></td>
            <% } else { %>
            <td class="leftCol-med labelField"><%=prop.getDisplayName()%>:</td>
            <%} %>
            <td>
                <% if (prop.getConfidential()) { %>

                <% if (prop.getValue() != null) { %>
                <div id="showHideButtonDivId" style="border:1px solid rgb(88, 105, 125);" class="leftCol-med">
                    <input id="cust_pro_prop_<%=fedConfig.getName()%>#<%=prop.getName()%>"
                           name="cust_pro_prop_<%=fedConfig.getName()%>#<%=prop.getName()%>" type="password"
                           value="<%=prop.getValue()%>"
                           style="  outline: none; border: none; min-width: 175px; max-width: 180px;"/>
       												<span id="showHideButtonId"
                                                          style=" float: right; padding-right: 5px;"> 
       													<a style="margin-top: 5px;" class="showHideBtn"
                                                           onclick="showHidePassword(this, 'cust_pro_prop_<%=fedConfig.getName()%>#<%=prop.getName()%>')">Show</a> 
       												</span>
                </div>
                <% } else { %>

                <div id="showHideButtonDivId" style="border:1px solid rgb(88, 105, 125);" class="leftCol-med">
                    <input id="cust_pro_prop_<%=fedConfig.getName()%>#<%=prop.getName()%>"
                           name="cust_pro_prop_<%=fedConfig.getName()%>#<%=prop.getName()%>" type="password"
                           style="  outline: none; border: none; min-width: 175px; max-width: 180px;"/>
       												<span id="showHideButtonId"
                                                          style=" float: right; padding-right: 5px;"> 
       													<a style="margin-top: 5px;" class="showHideBtn"
                                                           onclick="showHidePassword(this, 'cust_pro_prop_<%=fedConfig.getName()%>#<%=prop.getName()%>')">Show</a> 
       												</span>
                </div>

                <% } %>

                <% } else { %>

                <% if (prop.getValue() != null) { %>
                <input id="cust_pro_prop_<%=fedConfig.getName()%>#<%=prop.getName()%>"
                       name="cust_pro_prop_<%=fedConfig.getName()%>#<%=prop.getName()%>" type="text"
                       value="<%=prop.getValue()%>"/>
                <% } else { %>
                <input id="cust_pro_prop_<%=fedConfig.getName()%>#<%=prop.getName()%>"
                       name="cust_pro_prop_<%=fedConfig.getName()%>#<%=prop.getName()%>" type="text">
                <% } %>

                <% } %>

                <%
                    if (prop.getDescription() != null) { %>
                <div class="sectionHelp"><%=prop.getDescription()%>
                </div>
                <%} %>
            </td>
        </tr>
        <%
                    }
                }
            }
        %>

    </table>
</div>

<%
                }
            }
        }
    }
%>

</div>


</div>


<!-- sectionSub Div -->
<div class="buttonRow">
    <% if (identityProvider != null) { %>
    <input type="button" value="<fmt:message key='update'/>" onclick="idpMgtUpdate();"/>
    <% } else { %>
    <input type="button" value="<fmt:message key='register'/>" onclick="idpMgtUpdate();"/>
    <% } %>
    <input type="button" value="<fmt:message key='cancel'/>" onclick="idpMgtCancel();"/>
</div>
</form>
</div>
</div>

</fmt:bundle>
