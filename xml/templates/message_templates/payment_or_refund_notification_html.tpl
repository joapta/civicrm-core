<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
 <title></title>
</head>
<body>

{capture assign=headerStyle}colspan="2" style="text-align: left; padding: 4px; border-bottom: 1px solid #999; background-color: #eee;"{/capture}
{capture assign=labelStyle }style="padding: 4px; border-bottom: 1px solid #999; background-color: #f7f7f7;"{/capture}
{capture assign=valueStyle }style="padding: 4px; border-bottom: 1px solid #999;"{/capture}
{capture assign=emptyBlockStyle }style="padding: 10px; border-bottom: 1px solid #999;background-color: #f7f7f7;"{/capture}
{capture assign=emptyBlockValueStyle }style="padding: 10px; border-bottom: 1px solid #999;"{/capture}

 <table id="crm-event_receipt" style="font-family: Arial, Verdana, sans-serif; text-align: left; width:100%; max-width:700px; padding:0; margin:0; border:0px;">

  <!-- BEGIN HEADER -->
  <!-- You can add table row(s) here with logo or other header elements -->
  <!-- END HEADER -->

  <!-- BEGIN CONTENT -->
  <tr>
    <td>
      {assign var="greeting" value="{contact.email_greeting}"}{if $greeting}<p>{$greeting},</p>{/if}
      {if $isRefund}
        <p>{ts}A refund has been issued based on changes in your registration selections.{/ts}</p>
      {else}
        <p>{ts}Below you will find a receipt for this payment.{/ts}</p>
        {if $paymentsComplete}
          <p>{ts}Thank you for completing this contribution.{/ts}</p>
        {/if}
      {/if}
    </td>
  </tr>
  <tr>
   <td>
    <table style="border: 1px solid #999; margin: 1em 0em 1em; border-collapse: collapse; width:100%;">
    {if $isRefund}
      <tr>
        <th {$headerStyle}>{ts}Refund Details{/ts}</th>
      </tr>
      <tr>
        <td {$labelStyle}>
        {ts}This Refund Amount{/ts}
        </td>
        <td {$valueStyle}>
        {$refundAmount|crmMoney}
        </td>
      </tr>
    {else}
      <tr>
        <th {$headerStyle}>{ts}Payment Details{/ts}</th>
      </tr>
      <tr>
        <td {$labelStyle}>
        {ts}This Payment Amount{/ts}
        </td>
        <td {$valueStyle}>
        {$paymentAmount|crmMoney}
        </td>
      </tr>
    {/if}
    {if $receive_date}
      <tr>
        <td {$labelStyle}>
        {ts}Transaction Date{/ts}
        </td>
        <td {$valueStyle}>
        {$receive_date|crmDate}
        </td>
      </tr>
    {/if}
    {if !empty($trxn_id)}
      <tr>
        <td {$labelStyle}>
        {ts}Transaction #{/ts}
        </td>
        <td {$valueStyle}>
        {$trxn_id}
        </td>
      </tr>
    {/if}
    {if !empty($paidBy)}
      <tr>
        <td {$labelStyle}>
        {ts}Paid By{/ts}
        </td>
        <td {$valueStyle}>
        {$paidBy}
        </td>
      </tr>
    {/if}
    {if !empty($checkNumber)}
      <tr>
        <td {$labelStyle}>
        {ts}Check Number{/ts}
        </td>
        <td {$valueStyle}>
        {$checkNumber}
        </td>
      </tr>
    {/if}

  <tr>
    <th {$headerStyle}>{ts}Contribution Details{/ts}</th>
  </tr>
  {if isset($totalAmount)}
  <tr>
    <td {$labelStyle}>
      {ts}Total Fee{/ts}
    </td>
    <td {$valueStyle}>
      {$totalAmount|crmMoney}
    </td>
  </tr>
  {/if}
  {if isset($totalPaid)}
  <tr>
    <td {$labelStyle}>
      {ts}Total Paid{/ts}
    </td>
    <td {$valueStyle}>
      {$totalPaid|crmMoney}
    </td>
  </tr>
  {/if}
  {if isset($amountOwed)}
  <tr>
    <td {$labelStyle}>
      {ts}Balance Owed{/ts}
    </td>
    <td {$valueStyle}>
      {$amountOwed|crmMoney}
    </td> {* This will be zero after final payment. *}
  </tr>
  {/if}
  </table>

  </td>
  </tr>
    <tr>
      <td>
  <table style="border: 1px solid #999; margin: 1em 0em 1em; border-collapse: collapse; width:100%;">
    {if !empty($billingName) || !empty($address)}
          <tr>
            <th {$headerStyle}>
        {ts}Billing Name and Address{/ts}
            </th>
          </tr>
          <tr>
            <td colspan="2" {$valueStyle}>
        {if !empty($billingName)}{$billingName}{/if}<br />
        {if !empty($address)}{$address|nl2br}{/if}
            </td>
          </tr>
    {/if}
    {if !empty($credit_card_number)}
          <tr>
            <th {$headerStyle}>
        {ts}Credit Card Information{/ts}
            </th>
          </tr>
          <tr>
            <td colspan="2" {$valueStyle}>
        {$credit_card_type}<br />
        {$credit_card_number}<br />
        {ts}Expires:{/ts} {$credit_card_exp_date|truncate:7:''|crmDate}
            </td>
          </tr>
    {/if}
    {if $component eq 'event'}
    <tr>
      <th {$headerStyle}>
        {ts}Event Information and Location{/ts}
      </th>
    </tr>
    <tr>
      <td colspan="2" {$valueStyle}>
         {$event.event_title}<br />
        {$event.event_start_date|crmDate}{if $event.event_end_date}-{if $event.event_end_date|date_format:"%Y%m%d" == $event.event_start_date|date_format:"%Y%m%d"}{$event.event_end_date|crmDate:0:1}{else}{$event.event_end_date|crmDate}{/if}{/if}
      </td>
    </tr>

    {if !empty($event.participant_role)}
    <tr>
      <td {$labelStyle}>
        {ts}Participant Role{/ts}
      </td>
      <td {$valueStyle}>
        {$event.participant_role}
      </td>
    </tr>
    {/if}

    {if !empty($isShowLocation)}
    <tr>
      <td colspan="2" {$valueStyle}>
        {$location.address.1.display|nl2br}
      </td>
    </tr>
    {/if}

    {if !empty($location.phone.1.phone) || !empty($location.email.1.email)}
    <tr>
      <td colspan="2" {$labelStyle}>
        {ts}Event Contacts:{/ts}
      </td>
    </tr>
    {foreach from=$location.phone item=phone}
    {if $phone.phone}
          <tr>
            <td {$labelStyle}>
        {if $phone.phone_type}
        {$phone.phone_type_display}
        {else}
        {ts}Phone{/ts}
        {/if}
            </td>
            <td {$valueStyle}>
        {$phone.phone} {if $phone.phone_ext}&nbsp;{ts}ext.{/ts} {$phone.phone_ext}{/if}
            </td>
          </tr>
    {/if}
    {/foreach}
    {foreach from=$location.email item=eventEmail}
    {if $eventEmail.email}
          <tr>
            <td {$labelStyle}>
        {ts}Email{/ts}
            </td>
            <td {$valueStyle}>
        {$eventEmail.email}
            </td>
          </tr>
    {/if}
    {/foreach}
    {/if} {*phone block close*}
    {/if}
  </table>
      </td>
    </tr>

    </table>

 </body>
</html>
