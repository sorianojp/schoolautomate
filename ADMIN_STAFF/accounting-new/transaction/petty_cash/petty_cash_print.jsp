<%@ page language="java" import="utility.*, Accounting.Transaction, java.util.Vector"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
TD.borderBottomLeftRight {
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
TD.borderBottomLeft {
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
TD.borderBottom {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function PageAction(strAction) {
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}

function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	this.SubmitOnce('form_');
}

</script>
<body>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");	

//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-TRANSACTION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-DTR Entry (Manual)","petty_cash_update_payment_stat.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}
		
	Transaction transaction = new Transaction();
	String strPageAction = WI.fillTextValue("page_action");
	String strProceedClicked = WI.getStrValue(WI.fillTextValue("proceedClicked"),"0");
	String strPCIndex = null;	
	Vector vRetResult = null;
	Vector vChargedTo = null;
	double dAmount = 0d;
	boolean bolPageBreak = false;
	
	if(strPageAction.length() > 0){
	  if(transaction.operateOnPettyCashEntry(dbOP,request,Integer.parseInt(strPageAction)) == null){
	  	strErrMsg = transaction.getErrMsg();			
	  }	  
	}
	
	if(strProceedClicked.equals("1")){
		if (WI.fillTextValue("voucher_no").length() > 0){
		vRetResult = transaction.operateOnPettyCashEntry(dbOP,request,3);
			if(vRetResult == null){
				strErrMsg = transaction.getErrMsg();
			}else{
				strPCIndex = (String) vRetResult.elementAt(0);
				vChargedTo = transaction.operateOnChargeTo(dbOP,request,4,strPCIndex);
				if(((String)vRetResult.elementAt(11)).equals("1")){
					strErrMsg = "Payment released to payee";		
				}
			}
		}else{
			strErrMsg = "Enter Voucher Number";
		}
	}		
	
%>
<form name="form_" method="post" action="./petty_cash_update_payment_stat.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="26"><div align="center"></div></td>
    </tr>
  </table>
	<%if(strProceedClicked.equals("1") && vRetResult != null && vRetResult.size() > 0){
		strPCIndex = (String) vRetResult.elementAt(0);
	%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%
	  	strTemp = (String) vRetResult.elementAt(1);
	 %>
    <tr> 
      <td width="87%" height="26"><div align="right">&nbsp;</div></td>
      <td width="13%" valign="bottom"><div align="center"><%=WI.getStrValue(strTemp,"")%></div></td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="26" colspan="4"><div align="center"></div></td>
    </tr>
    <tr> 
      <td height="40" width="3%">&nbsp;</td>
      <td width="14%">&nbsp;</td>
      <td><div align="right"></div></td>
      <%
	  	strTemp = (String) vRetResult.elementAt(3);
	  %>
      <td width="18%" valign="bottom"><div align="center"><%=WI.getStrValue(strTemp,"")%></div></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <%
	  	strTemp = (String) vRetResult.elementAt(4);
	  %>
      <td colspan="2" valign="bottom"><%=WI.getStrValue(strTemp,"")%></td>
    </tr>
    <tr> 
      <td height="36">&nbsp;</td>
      <td>&nbsp;</td>
      <%
	  	strTemp = (String) vRetResult.elementAt(6);
		dAmount = Double.parseDouble(strTemp);
	  %>
      <td valign="bottom"><%=new ConversionTable().convertAmoutToFigure(dAmount,"Pesos","Centavos")%> <div align="right"></div></td>
      <%
	  	strTemp = (String) vRetResult.elementAt(6);
	  %>
      <td valign="bottom"><div align="center"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"")%>&nbsp;</div></td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="26">&nbsp;</td>
      <td width="97%">&nbsp;</td>
      <%
	  	strTemp = (String) vRetResult.elementAt(5);
	  %>
    </tr>
    <tr> 
      <td height="275">&nbsp;</td>
      <td valign="top"><%=WI.getStrValue(strTemp,"")%></td>
    </tr>
  </table>  
	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="0%" height="26">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
      <td width="25%">&nbsp;</td>
      <td width="9%">&nbsp;</td>
      <td width="24%" colspan="2"><div align="center"></div></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td colspan="3" rowspan="2" valign="top"> <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <%
		  if (vChargedTo.size()/4 <= 2){		  
		  for(int i = 0; i < vChargedTo.size() ; i +=4){%>
          <tr> 
            <td width="75%" height="25"><strong><%=(String)vChargedTo.elementAt(i+1)%> :: <%=(String)vChargedTo.elementAt(i+2)%></strong></td>
          </tr>
          <%}
		  }else{bolPageBreak = true;%>
          <tr> 
            <td width="75%" height="25"><div align="center"><strong>POST 
                FROM LIST</strong></div></td>
          </tr>
          <%}%>
        </table></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="26" width="0%">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2" align="center" valign="top">&nbsp;</td>
    </tr>
  </table>  
	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="26" width="2%">&nbsp;</td>
      <td width="23%" valign="bottom">&nbsp;</td>
      <td width="2%" valign="bottom">&nbsp;</td>
      <td width="23%" valign="bottom">&nbsp;</td>
      <td width="2%" valign="bottom">&nbsp;</td>
      <td width="23%" valign="bottom">&nbsp;</td>
      <td width="2%" valign="bottom">&nbsp;</td>
      <td width="23%" valign="bottom"><div align="center"></div></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <%
	  	strTemp = (String) vRetResult.elementAt(7);
	  %>
      <td valign="bottom"><div align="center"></div></td>
      <td>&nbsp;</td>
      <%
	  	strTemp = (String) vRetResult.elementAt(8);
	  %>
      <td valign="bottom"><div align="center"></div></td>
      <td>&nbsp;</td>
      <%
	  	strTemp = (String) vRetResult.elementAt(9);
	  %>
      <td valign="bottom"> <div align="center"></div></td>
      <td>&nbsp;</td>
      <td><div align="center">&nbsp;</div></td>
    </tr>
  </table>  
	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="26">&nbsp;</td>
      <td width="40%" height="26">&nbsp;</td>
      <td width="25%">&nbsp;</td>
      <td width="5%" height="26"><div align="right"></div></td>
      <td width="28%" height="26">&nbsp;</td>
    </tr>
  </table>
  <%}// end if strProceedClicked == 1%>
  <%if(bolPageBreak){%>
  <DIV style="page-break-before:always" >&nbsp;</DIV>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="18" colspan="5">Posting List for Petty Cash Voucher # <%=WI.getStrValue((String)vRetResult.elementAt(1),"")%> Dated <%=(String) vRetResult.elementAt(3)%></td>
    </tr>
    <tr> 
      <td height="19" colspan="5"><hr size="1"></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="15" class="borderBottom">&nbsp;</td>
      <td class="borderBottom">&nbsp;</td>
      <td class="borderBottom">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
	<% int iCount = 1;
	for(int i = 0; i < vChargedTo.size() ; i +=4,iCount++){%>
    <tr> 
      <td width="4%">&nbsp;</td>
      <td width="6%" height="18" class="borderBottomLeft"><div align="right"><%=iCount%>.&nbsp;</div></td>
      <td width="69%" class="borderBottomLeft">&nbsp;<%=(String)vChargedTo.elementAt(i+2)%></td>
      <td width="12%" class="borderBottomLeftRight"><div align="right"><strong><%=CommonUtil.formatFloat((String)vChargedTo.elementAt(i+3),true)%>&nbsp;</strong></div></td>
      <td width="9%">&nbsp;</td>
    </tr>
    <%}%>
  </table>
  <%}%>
  	
  <input type="hidden" name="voucher_no">
  <input type="hidden" name="info_index" value="<%=strPCIndex%>">
  <input type="hidden" name="page_action">
  <input type="hidden" name="proceedClicked" value="<%=WI.fillTextValue("proceedClicked")%>">	
</form>
</body>
<script language="JavaScript">
	window.print();
</script>
</html>
<%
dbOP.cleanUP();
%>