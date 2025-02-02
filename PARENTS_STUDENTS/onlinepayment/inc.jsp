<%
int iPgIndex      = Integer.parseInt(request.getParameter("pgIndex"));
%>    


   
<table border="0" cellpadding="0" cellspacing="0">
      <tr>
<%if(iPgIndex == 1){%>
        <td background="../../images/tableft_selected.gif" height="26" width="10">&nbsp;</td>
        <td width="60" bgcolor="#a9b9d1" align="center" class="tabFont">Summary</td>
        <td background="../../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../../images/tableft.gif" height="26" width="10">&nbsp;</td>
        <td width="60" bgcolor="#00468C" align="center"><a href="./user_summary.jsp">Summary</a></td>
        <td background="../../images/tabright.gif" width="10">&nbsp;</td>
<%}%>
        
<%if(iPgIndex == 2){%>
        <td background="../../images/tableft_selected.gif" height="26" width="10">&nbsp;</td>
        <td width="120" bgcolor="#a9b9d1" align="center" class="tabFont">Payment History</td>
        <td background="../../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../../images/tableft.gif" height="26" width="10">&nbsp;</td>
        <td width="120" bgcolor="#00468C" align="center"><a href="./payment_history.jsp">Payment History</a></td>
        <td background="../../images/tabright.gif" width="10">&nbsp;</td>
<%}%>
        
<%if(iPgIndex == 3){%>
        <td background="../../images/tableft_selected.gif" height="26" width="10">&nbsp;</td>
        <td width="120" bgcolor="#a9b9d1" align="center" class="tabFont">Make Payment</td>
        <td background="../../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../../images/tableft.gif" height="26" width="10">&nbsp;</td>
        <td width="120" bgcolor="#00468C" align="center"><a href="./make_payment.jsp">Make Payment</a></td>
        <td background="../../images/tabright.gif" width="10">&nbsp;</td>
<%}%>
<%if(iPgIndex == 4){%>
        <td background="../../images/tableft_selected.gif" height="26" width="10">&nbsp;</td>
        <td width="120" bgcolor="#a9b9d1" align="center" class="tabFont">Print Permit</td>
        <td background="../../images/tabright_selected.gif" width="10">&nbsp;</td>
<%}else{%>
        <td background="../../images/tableft.gif" height="26" width="10">&nbsp;</td>
        <td width="120" bgcolor="#00468C" align="center"><a href="./print_permit.jsp">Print Permit</a></td>
        <td background="../../images/tabright.gif" width="10">&nbsp;</td>
<%}%>

      </tr>
</table>
