{*
 +--------------------------------------------------------------------+
 | Copyright CiviCRM LLC. All rights reserved.                        |
 |                                                                    |
 | This work is published under the GNU AGPLv3 license with some      |
 | permitted exceptions and without any warranty. For full license    |
 | and copyright information, see https://civicrm.org/licensing       |
 +--------------------------------------------------------------------+
*}

{* Displays contribution/event fees when price set is used. *}
{foreach from=$lineItem item=value key=priceset}
  {if $value neq 'skip'}
    {if $lineItem|@count GT 1} {* Header for multi participant registration cases. *}
      {if $priceset GT 0}<br/>{/if}
      <strong>{ts}Participant {$priceset+1}{/ts}</strong>
      {$part.$priceset.info}
    {/if}
    <table>
      <tr class="columnheader">
        <th>{ts}Item{/ts}</th>
        {if $context EQ "Membership"}
          <th class="right">{ts}Fee{/ts}</th>
        {else}
          <th class="right">{ts}Qty{/ts}</th>
          <th class="right">{ts}Unit Price{/ts}</th>
          <th class="right">{ts}Total Price{/ts}</th>
          {if $context EQ "Contribution"  && $action eq 2}
            <th class="right">{ts}Paid{/ts}</th>
            <th class="right">{ts}Owing{/ts}</th>
            <th class="right">{ts}Amount of<br>Current Payment {/ts}</th>
          {/if}
        {/if}

        {if $pricesetFieldsCount}
          <th class="right">{ts}Total Participants{/ts}</th>{/if}
      </tr>
      {foreach from=$value item=line}
        <tr>
          <td>{if $line.field_title && $line.html_type neq 'Text'}{$line.field_title} &ndash; {$line.label}{else}{$line.label}{/if} {if $line.description}
              <div class="description">{$line.description}</div>{/if}</td>
          {if $context NEQ "Membership"}
            <td class="right">{$line.qty}</td>
            <td class="right">{$line.unit_price|crmMoney}</td>
          {/if}
          <td class="right">{$line.line_total|crmMoney}</td>
          {if $pricesetFieldsCount}
            <td class="right">{$line.participant_count}</td> {/if}
          {if $context EQ "Contribution" && $action eq 2}
            <td class="right">{$pricefildTotal.LineItems[$line.price_field_value_id]|crmMoney}</td>
            <td class="right">
              {assign var="fildTotal" value=$line.line_total-$pricefildTotal[$pricefildTotal.id][$line.price_field_value_id]}
              {$fildTotal|crmMoney}
            </td>
            <td class="left">$<input
              type='text' id='txt-price[{$line.price_field_value_id}]'
              name='txt-price[{$line.price_field_value_id}]' size='4'
              class='distribute'>&nbsp<input type='checkbox'
              id='cb-price[{$line.price_field_value_id}]'
              name='cb-price[{$line.price_field_value_id}]'
              price='{$fildTotal}' class='payFull'/></td>
          {/if}
        </tr>
      {/foreach}
      {if $context EQ "Contribution"  && $action eq 2}
        <tr>
          <td>
            {ts}Contribution Total{/ts}:
          </td>
          <td></td>
          <td></td>
          <td class="right">{$totalAmount|crmMoney}</td>
          <td class="right">{$pricefildTotal.total|crmMoney}</td>
          <td class="right">{assign var="total" value= $totalAmount-$pricefildTotal.total}{$total|crmMoney}</td>
          <td class="left"><h5 class='editPayment'></h5>
            {literal}
            <script type="text/javascript">
              CRM.$(function ($) {
                $(document).on('blur', '.distribute', function () {
                  var totalAmount = 0;
                  $('.distribute').each(function () {
                    if ($(this).val().length > 0) {
                      totalAmount = parseFloat(totalAmount) + parseFloat($(this).val());
                    }
                  });

                  $('.editPayment').text('$ ' + totalAmount);
                  var unlocateAmount = '{/literal}{$total}{literal}';
                  $('.unlocateAmount').text('$ ' + (unlocateAmount - totalAmount));
                });
              });
            </script>
            {/literal}

          </td>
        </tr>
        <tr>
          <td colspan=6 class="right"><strong>{ts}Unallocated Amount{/ts}</strong></td>
          <td><h5 class='unlocateAmount'>{$total|crmMoney} </h5></td>
        </tr>
      {/if}
    </table>
  {/if}
{/foreach}

<div class="crm-section no-label total_amount-section">
  <div class="content bold">
    {if $context EQ "Contribution"}
      {ts}Contribution Total{/ts}:
    {elseif $context EQ "Event"}
      {ts}Event Total{/ts}:
    {elseif $context EQ "Membership"}
      {ts}Membership Fee Total{/ts}:
    {else}
      {ts}Total Amount{/ts}:
    {/if}
    {$totalAmount|crmMoney}
  </div>
  <div class="content bold">
    {if $pricesetFieldsCount}
      {ts}Total Participants{/ts}:
      {foreach from=$lineItem item=pcount}
        {if $pcount neq 'skip'}
          {assign var="lineItemCount" value=0}

          {foreach from=$pcount item=p_count}
            {assign var="lineItemCount" value=$lineItemCount+$p_count.participant_count}
          {/foreach}
          {if $lineItemCount < 1 }
            {assign var="lineItemCount" value=1}
          {/if}
          {assign var="totalcount" value=$totalcount+$lineItemCount}
        {/if}
      {/foreach}
      {$totalcount}
    {/if}
  </div>
</div>

{if $hookDiscount.message}
  <div class="crm-section hookDiscount-section">
    <em>({$hookDiscount.message})</em>
  </div>
{/if}
