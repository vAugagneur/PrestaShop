{*
* 2007-2013 PrestaShop
*
* NOTICE OF LICENSE
*
* This source file is subject to the Academic Free License (AFL 3.0)
* that is bundled with this package in the file LICENSE.txt.
* It is also available through the world-wide-web at this URL:
* http://opensource.org/licenses/afl-3.0.php
* If you did not receive a copy of the license and are unable to
* obtain it through the world-wide-web, please send an email
* to license@prestashop.com so we can send you a copy immediately.
*
* DISCLAIMER
*
* Do not edit or add to this file if you wish to upgrade PrestaShop to newer
* versions in the future. If you wish to customize PrestaShop for your
* needs please refer to http://www.prestashop.com for more information.
*
*  @author PrestaShop SA <contact@prestashop.com>
*  @copyright  2007-2013 PrestaShop SA
*  @license    http://opensource.org/licenses/afl-3.0.php  Academic Free License (AFL 3.0)
*  International Registered Trademark & Property of PrestaShop SA
*}

{capture name=path}
	{if !isset($email_create)}{l s='Authentication'}{else}
		<a href="{$link->getPageLink('authentication', true)|escape:'html'}" rel="nofollow" title="{l s='Authentication'}">{l s='Authentication'}</a>
		<span class="navigation-pipe">{$navigationPipe}</span>{l s='Create your account'}
	{/if}
{/capture}

<script type="text/javascript">
// <![CDATA[
var idSelectedCountry = {if isset($smarty.post.id_state)}{$smarty.post.id_state|intval}{else}false{/if};
var countries = new Array();
var countriesNeedIDNumber = new Array();
var countriesNeedZipCode = new Array(); 
{if isset($countries)}
	{foreach from=$countries item='country'}
		{if isset($country.states) && $country.contains_states}
			countries[{$country.id_country|intval}] = new Array();
			{foreach from=$country.states item='state' name='states'}
				countries[{$country.id_country|intval}].push({ldelim}'id' : '{$state.id_state|intval}', 'name' : '{$state.name|addslashes}'{rdelim});
			{/foreach}
		{/if}
		{if $country.need_identification_number}
			countriesNeedIDNumber.push({$country.id_country|intval});
		{/if}
		{if isset($country.need_zip_code)}
			countriesNeedZipCode[{$country.id_country|intval}] = {$country.need_zip_code};
		{/if}
	{/foreach}
{/if}
$(function(){ldelim}
	$('.id_state option[value={if isset($smarty.post.id_state)}{$smarty.post.id_state|intval}{else}{if isset($address)}{$address->id_state|intval}{/if}{/if}]').attr('selected', true);
{rdelim});
//]]>
{literal}
$(document).ready(function() {
	$('#company').on('input',function(){
		vat_number();
	});
	vat_number();
	function vat_number()
	{
		if ($('#company').val() != '')
			$('#vat_number').show();
		else
			$('#vat_number').hide();
	}
});
{/literal}
</script>

<h1 class="page-heading">{if !isset($email_create)}{l s='Authentication'}{else}{l s='Create an account'}{/if}</h1>
{if !isset($back) || $back != 'my-account'}{assign var='current_step' value='login'}{include file="$tpl_dir./order-steps.tpl"}{/if}
{include file="$tpl_dir./errors.tpl"}
{assign var='stateExist' value=false}
{assign var="postCodeExist" value=false}
{if !isset($email_create)}
	<script type="text/javascript">
	{literal}
	$(document).ready(function(){
		// Retrocompatibility with 1.4
		if (typeof baseUri === "undefined" && typeof baseDir !== "undefined")
		baseUri = baseDir;
		$('#create-account_form').submit(function(){
			submitFunction();
			return false;
		});
	});
	function submitFunction()
	{
		$('#create_account_error').html('').hide();
		//send the ajax request to the server
		$.ajax({
			type: 'POST',
			url: baseUri,
			async: true,
			cache: false,
			dataType : "json",
			data: {
				controller: 'authentication',
				SubmitCreate: 1,
				ajax: true,
				email_create: $('#email_create').val(),
				back: $('input[name=back]').val(),
				token: token
			},
			success: function(jsonData)
			{
				if (jsonData.hasError)
				{
					var errors = '';
					for(error in jsonData.errors)
						//IE6 bug fix
						if(error != 'indexOf')
							errors += '<li>'+jsonData.errors[error]+'</li>';
					$('#create_account_error').html('<ol>'+errors+'</ol>').show();
				}
				else
				{
					// adding a div to display a transition
					$('#center_column').html('<div id="noSlide">'+$('#center_column').html()+'</div>');
					$('#noSlide').fadeOut('slow', function(){
						$('#noSlide').html(jsonData.page);
						// update the state (when this file is called from AJAX you still need to update the state)
						bindStateInputAndUpdate();
						$(this).fadeIn('slow', function(){
							document.location = '#account-creation';
							$('select.form-control').uniform();
						});
					});
				}
			},
			error: function(XMLHttpRequest, textStatus, errorThrown)
			{
				alert("TECHNICAL ERROR: unable to load form.\n\nDetails:\nError thrown: " + XMLHttpRequest + "\n" + 'Text status: ' + textStatus);
			}
		});
	}
	{/literal}
	</script>
	<!--{if isset($authentification_error)}
	<div class="alert alert-danger">
		{if {$authentification_error|@count} == 1}
			<p>{l s='There\'s at least one error'} :</p>
			{else}
			<p>{l s='There are %s errors' sprintf=[$account_error|@count]} :</p>
		{/if}
		<ol>
			{foreach from=$authentification_error item=v}
				<li>{$v}</li>
			{/foreach}
		</ol>
	</div>
	{/if}-->
    <div class="row">
    	<div class="col-xs-12 col-sm-6">
            <form action="{$link->getPageLink('authentication', true)|escape:'html'}" method="post" id="create-account_form" class="box">
            	
                <fieldset>
                    <h3 class="page-subheading">{l s='Create an account'}</h3>
                    <div class="form_content clearfix">
                        <p>{l s='Please enter your email address to create an account.'}</p>
                        <div class="alert alert-danger" id="create_account_error" style="display:none"></div>
                            <div class="form-group">
                                <label for="email_create">{l s='Email address'}</label>
                                <input type="text" class="is_required validate account_input form-control" data-validate="isEmail" id="email_create" name="email_create" value="{if isset($smarty.post.email_create)}{$smarty.post.email_create|stripslashes}{/if}" />
                            </div>
                            <div class="submit">
                                {if isset($back)}<input type="hidden" class="hidden" name="back" value="{$back|escape:'html':'UTF-8'}" />{/if}
                                <button class="btn btn-default button button-medium exclusive" type="submit" id="SubmitCreate" name="SubmitCreate"><span><i class="icon-user left"></i>{l s='Create an account'}</span></button>
                                <input type="hidden" class="hidden" name="SubmitCreate" value="{l s='Create an account'}" />
                            </div>
                    </div>
                </fieldset>
            </form>
        </div>
        <div class="col-xs-12 col-sm-6">
            <form action="{$link->getPageLink('authentication', true)|escape:'html'}" method="post" id="login_form" class="box">
                <fieldset>
                    <h3 class="page-subheading">{l s='Already registered?'}</h3>
                    <div class="form_content clearfix">
                        <div class="form-group">
                            <label for="email">{l s='Email address'}</label>
                            <input class="is_required validate account_input form-control" data-validate="isEmail" type="text" id="email" name="email" value="{if isset($smarty.post.email)}{$smarty.post.email|stripslashes}{/if}" />
                        </div>
                        <div class="form-group">
                            <label for="passwd">{l s='Password'}</label>
                            <span><input class="is_required validate account_input form-control" type="password" data-validate="isPasswd" id="passwd" name="passwd" value="{if isset($smarty.post.passwd)}{$smarty.post.passwd|stripslashes}{/if}" /></span>
                        </div>
                        <p class="lost_password form-group"><a href="{$link->getPageLink('password')|escape:'html'}" title="{l s='Recover your forgotten password'}" rel="nofollow">{l s='Forgot your password?'}</a></p>
                        <p class="submit">
                            {if isset($back)}<input type="hidden" class="hidden" name="back" value="{$back|escape:'html':'UTF-8'}" />{/if}
                            <button type="submit" id="SubmitLogin" name="SubmitLogin" class="button btn btn-default button-medium"><span><i class="icon-lock left"></i>{l s='Sign in'}</span></button>
                        </p>
                    </div>
                </fieldset>
            </form>
        </div>
	</div>
	{if isset($inOrderProcess) && $inOrderProcess && $PS_GUEST_CHECKOUT_ENABLED}
	<form action="{$link->getPageLink('authentication', true, NULL, "back=$back")|escape:'html'}" method="post" id="new_account_form" class="std clearfix">
    <div class="box">
		<fieldset>			
			<div id="opc_account_form" style="display: block; ">
            <h3 class="page-heading bottom-indent">{l s='Instant checkout'}</h3>
				<!-- Account -->
				<div class="required form-group">
					<label for="guest_email">{l s='Email address'} <sup>*</sup></label>
					<input type="text" class="is_required validate form-control" data-validate="isEmail" id="guest_email" name="guest_email" value="{if isset($smarty.post.guest_email)}{$smarty.post.guest_email}{/if}" />
				</div>
                <div class="cleafix gender-line">
					<label>{l s='Title'}</label>
					{foreach from=$genders key=k item=gender}
                    <div class="radio-inline">
                    	<label for="id_gender{$gender->id}" class="top">
						<input type="radio" name="id_gender" id="id_gender{$gender->id}" value="{$gender->id}"{if isset($smarty.post.id_gender) && $smarty.post.id_gender == $gender->id} checked="checked"{/if} />
						{$gender->name}</label>
                     </div>
					{/foreach}
                </div>
				<div class="required form-group">
					<label for="firstname">{l s='First name'} <sup>*</sup></label>
					<input type="text" class="is_required validate text form-control" data-validate="isName" id="firstname" name="firstname" onblur="$('#customer_firstname').val($(this).val());" value="{if isset($smarty.post.firstname)}{$smarty.post.firstname}{/if}" />
					<input type="hidden" class="text" id="customer_firstname" name="customer_firstname" value="{if isset($smarty.post.firstname)}{$smarty.post.firstname}{/if}" />
				</div>
				<div class="required form-group">
					<label for="lastname">{l s='Last name'} <sup>*</sup></label>
					<input type="text" class="is_required validate text form-control" data-validate="isName" id="lastname" name="lastname" onblur="$('#customer_lastname').val($(this).val());" value="{if isset($smarty.post.lastname)}{$smarty.post.lastname}{/if}" />
					<input type="hidden" class="text" id="customer_lastname" name="customer_lastname" value="{if isset($smarty.post.lastname)}{$smarty.post.lastname}{/if}" />
				</div>
				<div class="form-group date-select">
					<label>{l s='Date of Birth'}</label>
                    <div class="row">
                    	<div class="col-xs-4">
                            <select id="days" name="days" class="form-control">
                                <option value="">-</option>
                                {foreach from=$days item=day}
                                    <option value="{$day}" {if ($sl_day == $day)} selected="selected"{/if}>{$day}&nbsp;&nbsp;</option>
                                {/foreach}
                            </select>
                            {*
                                  {l s='January'}
                                  {l s='February'}
                                  {l s='March'}
                                  {l s='April'}
                                  {l s='May'}
                                  {l s='June'}
                                  {l s='July'}
                                  {l s='August'}
                                  {l s='September'}
                                  {l s='October'}
                                  {l s='November'}
                                  {l s='December'}
                              *}
                        </div>
                        <div class="col-xs-4">
                        	<select id="months" name="months" class="form-control">
                            <option value="">-</option>
                            {foreach from=$months key=k item=month}
                                <option value="{$k}" {if ($sl_month == $k)} selected="selected"{/if}>{l s=$month}&nbsp;</option>
                            {/foreach}
                        </select>
                        </div>
                        <div class="col-xs-4">
                        	<select id="years" name="years" class="form-control">
                            <option value="">-</option>
                            {foreach from=$years item=year}
                                <option value="{$year}" {if ($sl_year == $year)} selected="selected"{/if}>{$year}&nbsp;&nbsp;</option>
                            {/foreach}
                        </select>
                        </div>
                    </div>
				</div>
				{if isset($newsletter) && $newsletter}
					<div class="checkbox">
                    	<label for="newsletter">
						<input type="checkbox" name="newsletter" id="newsletter" value="1" {if isset($smarty.post.newsletter) && $smarty.post.newsletter == '1'}checked="checked"{/if} autocomplete="off"/>
						{l s='Sign up for our newsletter!'}</label>
					</div>
					<div class="checkbox">
                    	<label for="optin">
						<input type="checkbox" name="optin" id="optin" value="1" {if isset($smarty.post.optin) && $smarty.post.optin == '1'}checked="checked"{/if} autocomplete="off"/>
						{l s='Receive special offers from our partners!'}</label>
					</div>
				{/if}
				<h3 class="page-heading bottom-indent top-indent">{l s='Delivery address'}</h3>
				{foreach from=$dlv_all_fields item=field_name}
					{if $field_name eq "company"}
						<div class="text form-group">
							<label for="company">{l s='Company'}</label>
							<input type="text" class="text form-control" id="company" name="company" value="{if isset($smarty.post.company)}{$smarty.post.company}{/if}" />
						</div>
						{elseif $field_name eq "vat_number"}
						<div id="vat_number" style="display:none;">
							<div class="text form-group">
								<label for="vat_number">{l s='VAT number'}</label>
								<input type="text" class="text form-control" name="vat_number" value="{if isset($smarty.post.vat_number)}{$smarty.post.vat_number}{/if}" />
							</div>
						</div>
						{elseif $field_name eq "address1"}
						<div class="required form-group">
							<label for="address1">{l s='Address'} <sup>*</sup></label>
							<input type="text" class="form-control" name="address1" id="address1" value="{if isset($smarty.post.address1)}{$smarty.post.address1}{/if}" />
						</div>
						{elseif $field_name eq "postcode"}
						{assign var='postCodeExist' value=true}
						<div class="required postcode form-group">
							<label for="postcode">{l s='Zip / Postal Code'} <sup>*</sup></label>
							<input type="text" class="form-control" name="postcode" id="postcode" value="{if isset($smarty.post.postcode)}{$smarty.post.postcode}{/if}" onblur="$('#postcode').val($('#postcode').val().toUpperCase());" />
						</div>
						{elseif $field_name eq "city"}
						<div class="required form-group">
							<label for="city">{l s='City'} <sup>*</sup></label>
							<input type="text" class="form-control" name="city" id="city" value="{if isset($smarty.post.city)}{$smarty.post.city}{/if}" />
						</div>
						<!--
							   if customer hasn't update his layout address, country has to be verified
							   but it's deprecated
						   -->
						{elseif $field_name eq "Country:name" || $field_name eq "country"}
						<div class="required select form-group">
							<label for="id_country">{l s='Country'} <sup>*</sup></label>
							<select name="id_country" id="id_country" class="form-control">
								{foreach from=$countries item=v}
									<option value="{$v.id_country}" {if ($sl_country == $v.id_country)} selected="selected"{/if}>{$v.name}</option>
								{/foreach}
							</select>
						</div>
						{elseif $field_name eq "State:name"}
						{assign var='stateExist' value=true}
						<div class="required id_state select form-group">
							<label for="id_state">{l s='State'} <sup>*</sup></label>
							<select name="id_state" id="id_state" class="form-control">
								<option value="">-</option>
							</select>
						</div>
						{elseif $field_name eq "phone"}
						<div class="{if isset($one_phone_at_least) && $one_phone_at_least}required {/if}text form-group">
							<label for="phone">{l s='Phone'}{if isset($one_phone_at_least) && $one_phone_at_least} <sup>*</sup>{/if}</label>
							<input type="text" class="text form-control" name="phone" id="phone" value="{if isset($smarty.post.phone)}{$smarty.post.phone}{/if}"/>
						</div>
					{/if}
				{/foreach}
				{if $stateExist eq false}
					<div class="required id_state select unvisible form-group">
						<label for="id_state">{l s='State'} <sup>*</sup></label>
						<select name="id_state" id="id_state" class="form-control">
							<option value="">-</option>
						</select>
					</div>
				{/if}
				{if $postCodeExist eq false}
					<div class="required postcode text unvisible form-group">
						<label for="postcode">{l s='Zip / Postal Code'} <sup>*</sup></label>
						<input type="text" class="text form-control" name="postcode" id="postcode" value="{if isset($smarty.post.postcode)}{$smarty.post.postcode}{/if}" onblur="$('#postcode').val($('#postcode').val().toUpperCase());" />
					</div>
				{/if}				
				<input type="hidden" name="alias" id="alias" value="{l s='My address'}" />
				<input type="hidden" name="is_new_customer" id="is_new_customer" value="0" />
				<!-- END Account -->
			</div>
		</fieldset>
		<fieldset class="account_creation dni">
			<h3 class="page-subheading">{l s='Tax identification'}</h3>
			<p class="required text form-group">
				<label for="dni">{l s='Identification number'}</label>
				<input type="text" class="text form-control" name="dni" id="dni" value="{if isset($smarty.post.dni)}{$smarty.post.dni}{/if}" />
				<span class="form_info">{l s='DNI / NIF / NIE'}</span>
			</p>
		</fieldset>
		{$HOOK_CREATE_ACCOUNT_FORM}
        </div>
		<p class="cart_navigation required submit clearfix">
			<span><sup>*</sup>{l s='Required field'}</span>
			<input type="hidden" name="display_guest_checkout" value="1" />
            <button type="submit" class="button btn btn-default button-medium" name="submitGuestAccount" id="submitGuestAccount"><span>{l s='Proceed to checkout'}<i class="icon-chevron-right right"></i></span></button>
		</p>
	</form>
	{/if}
{else}
	<!--{if isset($account_error)}
	<div class="error">
		{if {$account_error|@count} == 1}
			<p>{l s='There\'s at least one error'} :</p>
			{else}
			<p>{l s='There are %s errors' sprintf=[$account_error|@count]} :</p>
		{/if}
		<ol>
			{foreach from=$account_error item=v}
				<li>{$v}</li>
			{/foreach}
		</ol>
	</div>
	{/if}-->
<form action="{$link->getPageLink('authentication', true)|escape:'html'}" method="post" id="account-creation_form" class="std box">
        {$HOOK_CREATE_ACCOUNT_TOP}
        <fieldset class="account_creation">
            <h3 class="page-subheading">{l s='Your personal information'}</h3>
            <div class="clearfix">
            <label>{l s='Title'}</label><br />
                {foreach from=$genders key=k item=gender}
                <div class="radio-inline">
                    <label for="id_gender{$gender->id}" class="top">
                    <input type="radio" name="id_gender" id="id_gender{$gender->id}" value="{$gender->id}" {if isset($smarty.post.id_gender) && $smarty.post.id_gender == $gender->id}checked="checked"{/if} />
                    {$gender->name}</label>
                </div>
                {/foreach}
            </div>
            <div class="required form-group">
                <label for="customer_firstname">{l s='First name'} <sup>*</sup></label>
                <input onkeyup="$('#firstname').val(this.value);" type="text" class="is_required validate form-control" data-validate="isName" id="customer_firstname" name="customer_firstname" value="{if isset($smarty.post.customer_firstname)}{$smarty.post.customer_firstname}{/if}" />
            </div>
            <div class="required form-group">
                <label for="customer_lastname">{l s='Last name'} <sup>*</sup></label>
                <input onkeyup="$('#lastname').val(this.value);" type="text" class="is_required validate form-control" data-validate="isName" id="customer_lastname" name="customer_lastname" value="{if isset($smarty.post.customer_lastname)}{$smarty.post.customer_lastname}{/if}" />
            </div>
            <div class="required form-group">
                <label for="email">{l s='Email'} <sup>*</sup></label>
                <input type="text" class="is_required validate form-control" data-validate="isEmail" id="email" name="email" value="{if isset($smarty.post.email)}{$smarty.post.email}{/if}" />
            </div>
            <div class="required password form-group">
                <label for="passwd">{l s='Password'} <sup>*</sup></label>
                <input type="password" class="is_required validate form-control" data-validate="isPasswd" name="passwd" id="passwd" />
                <span class="form_info">{l s='(Five characters minimum)'}</span>
            </div> 
            <div class="form-group">
                <label>{l s='Date of Birth'}</label>
                <div class="row">
                    <div class="col-xs-4">
                        <select id="days" name="days" class="form-control">
                            <option value="">-</option>
                            {foreach from=$days item=day}
                                <option value="{$day}" {if ($sl_day == $day)} selected="selected"{/if}>{$day}&nbsp;&nbsp;</option>
                            {/foreach}
                        </select>
                        {*
                            {l s='January'}
                            {l s='February'}
                            {l s='March'}
                            {l s='April'}
                            {l s='May'}
                            {l s='June'}
                            {l s='July'}
                            {l s='August'}
                            {l s='September'}
                            {l s='October'}
                            {l s='November'}
                            {l s='December'}
                        *}
                    </div>
                    <div class="col-xs-4">
                        <select id="months" name="months" class="form-control">
                            <option value="">-</option>
                            {foreach from=$months key=k item=month}
                                <option value="{$k}" {if ($sl_month == $k)} selected="selected"{/if}>{l s=$month}&nbsp;</option>
                            {/foreach}
                        </select>
                    </div>
                    <div class="col-xs-4">
                        <select id="years" name="years" class="form-control">
                            <option value="">-</option>
                            {foreach from=$years item=year}
                                <option value="{$year}" {if ($sl_year == $year)} selected="selected"{/if}>{$year}&nbsp;&nbsp;</option>
                            {/foreach}
                        </select>
                    </div>
                </div>
            </div>
            {if $newsletter}
            <div class="checkbox">
                <input type="checkbox" name="newsletter" id="newsletter" value="1" {if isset($smarty.post.newsletter) AND $smarty.post.newsletter == 1} checked="checked"{/if} autocomplete="off"/>
                <label for="newsletter">{l s='Sign up for our newsletter!'}</label>
            </div>
            <div class="checkbox">
                <input type="checkbox"name="optin" id="optin" value="1" {if isset($smarty.post.optin) AND $smarty.post.optin == 1} checked="checked"{/if} autocomplete="off"/>
                <label for="optin">{l s='Receive special offers from our partners!'}</label>
            </div>
            {/if}
        </fieldset>
        {if $b2b_enable}
        <fieldset class="account_creation">
            <h3 class="page-subheading">{l s='Your company information'}</h3>
            <p class="form-group">
                <label for="">{l s='Company'}</label>
                <input type="text" class="form-control" id="company" name="company" value="{if isset($smarty.post.company)}{$smarty.post.company}{/if}" />
            </p>
            <p class="form-group">
                <label for="siret">{l s='SIRET'}</label>
                <input type="text" class="form-control" id="siret" name="siret" value="{if isset($smarty.post.siret)}{$smarty.post.siret}{/if}" />
            </p>
            <p class="form-group">
                <label for="ape">{l s='APE'}</label>
                <input type="text" class="form-control" id="ape" name="ape" value="{if isset($smarty.post.ape)}{$smarty.post.ape}{/if}" />
            </p>
            <p class="form-group">
                <label for="website">{l s='Website'}</label>
                <input type="text" class="form-control" id="website" name="website" value="{if isset($smarty.post.website)}{$smarty.post.website}{/if}" />
            </p>
        </fieldset>
        {/if}
        {if isset($PS_REGISTRATION_PROCESS_TYPE) && $PS_REGISTRATION_PROCESS_TYPE}
        <fieldset class="account_creation">
            <h3 class="page-subheading">{l s='Your address'}</h3>
            {foreach from=$dlv_all_fields item=field_name}
                {if $field_name eq "company"}
                    {if !$b2b_enable}
                        <p class="form-group">
                            <label for="company">{l s='Company'}</label>
                            <input type="text" class="form-control" id="company" name="company" value="{if isset($smarty.post.company)}{$smarty.post.company}{/if}" />
                        </p>
                    {/if}
                {elseif $field_name eq "vat_number"}
                    <div id="vat_number" style="display:none;">
                        <p class="form-group">
                            <label for="vat_number">{l s='VAT number'}</label>
                            <input type="text" class="form-control" name="vat_number" value="{if isset($smarty.post.vat_number)}{$smarty.post.vat_number}{/if}" />
                        </p>
                    </div>
                {elseif $field_name eq "firstname"}
                    <p class="required form-group">
                        <label for="firstname">{l s='First name'} <sup>*</sup></label>
                        <input type="text" class="form-control" id="firstname" name="firstname" value="{if isset($smarty.post.firstname)}{$smarty.post.firstname}{/if}" />
                    </p>
                {elseif $field_name eq "lastname"}
                    <p class="required form-group">
                        <label for="lastname">{l s='Last name'} <sup>*</sup></label>
                        <input type="text" class="form-control" id="lastname" name="lastname" value="{if isset($smarty.post.lastname)}{$smarty.post.lastname}{/if}" />
                    </p>
                {elseif $field_name eq "address1"}
                    <p class="required form-group">
                        <label for="address1">{l s='Address'} <sup>*</sup></label>
                        <input type="text" class="form-control" name="address1" id="address1" value="{if isset($smarty.post.address1)}{$smarty.post.address1}{/if}" />
                        <span class="inline-infos">{l s='Street address, P.O. Box, Company name, etc.'}</span>
                    </p>
                {elseif $field_name eq "address2"}
                    <p class="form-group">
                        <label for="address2">{l s='Address (Line 2)'}</label>
                        <input type="text" class="form-control" name="address2" id="address2" value="{if isset($smarty.post.address2)}{$smarty.post.address2}{/if}" />
                        <span class="inline-infos">{l s='Apartment, suite, unit, building, floor, etc...'}</span>
                    </p>
                {elseif $field_name eq "postcode"}
                {assign var='postCodeExist' value=true}
                    <p class="required postcode form-group">
                        <label for="postcode">{l s='Zip / Postal Code'} <sup>*</sup></label>
                        <input type="text" class="form-control" name="postcode" id="postcode" value="{if isset($smarty.post.postcode)}{$smarty.post.postcode}{/if}" onkeyup="$('#postcode').val($('#postcode').val().toUpperCase());" />
                    </p>
                {elseif $field_name eq "city"}
                    <p class="required form-group">
                        <label for="city">{l s='City'} <sup>*</sup></label>
                        <input type="text" class="form-control" name="city" id="city" value="{if isset($smarty.post.city)}{$smarty.post.city}{/if}" />
                    </p>
                    <!--
                        if customer hasn't update his layout address, country has to be verified
                        but it's deprecated
                    -->
                {elseif $field_name eq "Country:name" || $field_name eq "country"}
                    <p class="required select form-group">
                        <label for="id_country">{l s='Country'} <sup>*</sup></label>
                        <select name="id_country" id="id_country" class="form-control">
                            <option value="">-</option>
                            {foreach from=$countries item=v}
                            <option value="{$v.id_country}" {if ($sl_country == $v.id_country)} selected="selected"{/if}>{$v.name}</option>
                            {/foreach}
                        </select>
                    </p>
                {elseif $field_name eq "State:name" || $field_name eq 'state'}
                    {assign var='stateExist' value=true}
                    <p class="required id_state select form-group">
                        <label for="id_state">{l s='State'} <sup>*</sup></label>
                        <select name="id_state" id="id_state" class="form-control">
                            <option value="">-</option>
                        </select>
                    </p>
                {/if}
            {/foreach}
            {if $postCodeExist eq false}
                <p class="required postcode form-group unvisible">
                    <label for="postcode">{l s='Zip / Postal Code'} <sup>*</sup></label>
                    <input type="text" class="form-control" name="postcode" id="postcode" value="{if isset($smarty.post.postcode)}{$smarty.post.postcode}{/if}" onkeyup="$('#postcode').val($('#postcode').val().toUpperCase());" />
                </p>
            {/if}		
            {if $stateExist eq false}
                <p class="required id_state select unvisible form-group">
                    <label for="id_state">{l s='State'} <sup>*</sup></label>
                    <select name="id_state" id="id_state" class="form-control">
                        <option value="">-</option>
                    </select>
                </p>
            {/if}
            <p class="textarea form-group">
                <label for="other">{l s='Additional information'}</label>
                <textarea class="form-control" name="other" id="other" cols="26" rows="3">{if isset($smarty.post.other)}{$smarty.post.other}{/if}</textarea>
            </p>
            {if isset($one_phone_at_least) && $one_phone_at_least}
                <p class="inline-infos">{l s='You must register at least one phone number.'}</p>
            {/if}
            <p class="form-group">
                <label for="phone">{l s='Home phone'}</label>
                <input type="text" class="form-control" name="phone" id="phone" value="{if isset($smarty.post.phone)}{$smarty.post.phone}{/if}" />
            </p>
            <p class="{if isset($one_phone_at_least) && $one_phone_at_least}required {/if} form-group">
                <label for="phone_mobile">{l s='Mobile phone'}{if isset($one_phone_at_least) && $one_phone_at_least} <sup>*</sup>{/if}</label>
                <input type="text" class="form-control" name="phone_mobile" id="phone_mobile" value="{if isset($smarty.post.phone_mobile)}{$smarty.post.phone_mobile}{/if}" />
            </p>
            <p class="required form-group" id="address_alias">
                <label for="alias">{l s='Assign an address alias for future reference.'} <sup>*</sup></label>
                <input type="text" class="form-control" name="alias" id="alias" value="{if isset($smarty.post.alias)}{$smarty.post.alias}{else}{l s='My address'}{/if}" />
            </p>
        </fieldset>
        <fieldset class="account_creation dni">
            <h3 class="page-subheading">{l s='Tax identification'}</h3>
            <p class="required form-group">
                <label for="dni">{l s='Identification number'} <sup>*</sup></label>
                <input type="text" class="form-control" name="dni" id="dni" value="{if isset($smarty.post.dni)}{$smarty.post.dni}{/if}" />
                <span class="form_info">{l s='DNI / NIF / NIE'}</span>
            </p>
        </fieldset>
        {/if}
        {$HOOK_CREATE_ACCOUNT_FORM}
        <div class="submit clearfix">
            <input type="hidden" name="email_create" value="1" />
            <input type="hidden" name="is_new_customer" value="1" />
            {if isset($back)}<input type="hidden" class="hidden" name="back" value="{$back|escape:'html':'UTF-8'}" />{/if}
            <button type="submit" name="submitAccount" id="submitAccount" class="btn btn-default button button-medium"><span>{l s='Register'}<i class="icon-chevron-right right"></i></span></button>
            <p class="pull-right required"><span><sup>*</sup>{l s='Required field'}</span></p>
        </div>
</form>
<script>
$(document).ready(function () {
	$("select.form-control,input[type='radio'],input[type='checkbox']").uniform(); 
});
</script>
{/if}