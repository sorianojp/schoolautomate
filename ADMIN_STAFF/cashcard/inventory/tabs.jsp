<%
int iPgIndex      = Integer.parseInt(request.getParameter("pgIndex"));
 %>    <table border="0" cellpadding="0" cellspacing="0">
      <tr>
<%if(iPgIndex == 1){%>
        <td background="../../../images/tableft_selected.gif" height="24" width="10">&nbsp;</td>
        <td width="120" bgcolor="#a9b9d1" align="center" class="tabFont">Inventory Summary </td>
        <td background="../../../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../../../images/tableft.gif" height="24" width="10">&nbsp;</td>
        <td width="120" bgcolor="#00468C" align="center"><a href="inv_summary.jsp?pgIndex=1">Inventory Summary </a></td>
        <td background="../../../images/tabright.gif" width="10">&nbsp;</td>
<%}
if(iPgIndex == 4){%>
        <td background="../../../images/tableft_selected.gif" height="24" width="10">&nbsp;</td>
        <td width="100" bgcolor="#a9b9d1" align="center" class="tabFont">Canteen items </td>
        <td background="../../../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../../../images/tableft.gif" height="24" width="10">&nbsp;</td>
        <td width="100" bgcolor="#00468C" align="center"><a href="inv_items.jsp?pgIndex=4">Canteen items </a></td>
        <td background="../../../images/tabright.gif" width="10">&nbsp;</td>
<%}
if(iPgIndex == 7){%>
        <td background="../../../images/tableft_selected.gif" height="24" width="10">&nbsp;</td>
        <td width="150" bgcolor="#a9b9d1" align="center" class="tabFont">Inventory Log</td>
        <td background="../../../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../../../images/tableft.gif" height="24" width="10">&nbsp;</td>
        <td width="150" bgcolor="#00468C" align="center"><a href="inv_log_new.jsp?pgIndex=7">Inventory Log</a></td>
        <td background="../../../images/tabright.gif" width="10">&nbsp;</td>
<%}
//if(iPgIndex == 5){%>
       <!-- <td background="../../../images/tableft_selected.gif" height="24" width="10">&nbsp;</td>
        <td width="150" bgcolor="#a9b9d1" align="center" class="tabFont">Item Beginning Balance</td>
        <td background="../../../images/tabright_selected.gif" width="10">&nbsp;</td>-->
<%//}else{%>
        <!--<td background="../../../images/tableft.gif" height="24" width="10">&nbsp;</td>
        <td width="150" bgcolor="#00468C" align="center"><a href="inv_beginning_bal.jsp?pgIndex=5">Item Beginning Balance</a></td>
        <td background="../../../images/tabright.gif" width="10">&nbsp;</td>-->
<%//}
//if(iPgIndex == 2){%>
        <!--<td background="../../../images/tableft_selected.gif" height="24" width="10">&nbsp;</td>
        <td width="100" bgcolor="#a9b9d1" align="center" class="tabFont">Inventory Log</td>
        <td background="../../../images/tabright_selected.gif" width="10">&nbsp;</td>-->
<%//}else{%>
        <!--<td background="../../../images/tableft.gif" height="24" width="10">&nbsp;</td>
        <td width="100" bgcolor="#00468C" align="center"><a href="inv_log.jsp?pgIndex=2">Inventory Log</a></td>
        <td background="../../../images/tabright.gif" width="10">&nbsp;</td>-->
<%//}
if(iPgIndex == 6){%>
        <td background="../../../images/tableft_selected.gif" height="24" width="10">&nbsp;</td>
        <td width="130" bgcolor="#a9b9d1" align="center" class="tabFont">Inventory Adjustment</td>
        <td background="../../../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../../../images/tableft.gif" height="24" width="10">&nbsp;</td>
        <td width="130" bgcolor="#00468C" align="center"><a href="inv_adjust.jsp?pgIndex=6">Inventory Adjustment</a></td>
        <td background="../../../images/tabright.gif" width="10">&nbsp;</td>
<%}
if(iPgIndex == 3){%>
        <td background="../../../images/tableft_selected.gif" height="24" width="10">&nbsp;</td>
        <td width="120" bgcolor="#a9b9d1" align="center" class="tabFont">Item Stock Card</td>
        <td background="../../../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../../../images/tableft.gif" height="24" width="10">&nbsp;</td>
        <td width="120" bgcolor="#00468C" align="center"><a href="inv_stock_card.jsp?pgIndex=3">Item Stock Card</a></td>
        <td background="../../../images/tabright.gif" width="10">&nbsp;</td>
<%}
if(iPgIndex == 10){%>
        <td background="../../../images/tableft_selected.gif" height="24" width="10">&nbsp;</td>
        <td width="120" bgcolor="#a9b9d1" align="center" class="tabFont">Inventory Report</td>
        <td background="../../../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../../../images/tableft.gif" height="24" width="10">&nbsp;</td>
        <td width="120" bgcolor="#00468C" align="center"><a href="inv_log_new_report.jsp?pgIndex=10">Inventory Report</a></td>
        <td background="../../../images/tabright.gif" width="10">&nbsp;</td>
<%}
%>
		<td width="50">&nbsp;</td>
      </tr>
      
	</table>
