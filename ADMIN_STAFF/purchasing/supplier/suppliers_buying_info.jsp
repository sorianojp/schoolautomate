<%@ page language="java" import="utility.*,java.util.Vector,purchasing.Supplier" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.proceedClicked.value = "";
	document.form_.pageReloaded.value = "1";
	this.SubmitOnce('form_');
}
function FocusSupplierCode() {
	document.form_.supplier_code.focus();
}

function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	document.form_.pageAction.value = "";	
	this.SubmitOnce('form_');
}

function PageAction(strAction,strInfoIndex){
	document.form_.pageAction.value = strAction;
	document.form_.proceedClicked.value = "";
	document.form_.pageReloaded.value = "1";
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce('form_');
}
function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function OpenSearch() {
	var pgLoc = "./search_supplier.jsp?opner_info=form_.supplier_code";
	var win=window.open(pgLoc,"SearchWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>
<%
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-SUPPLIERS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	DBOperation dbOP = null;	
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-SUPPLIERS-Supplier Buying Info","suppliers_buying_info.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.

	Supplier SUP = new Supplier();
	String strErrMsg  = null;
	String strTemp = null;
	String strTerm = null;
	Vector vBuyingInfo = new Vector();
	String[] astrTerm   = {"Cash on Delivery (COD)", "Prepaid", "Given No. of Days", "Specific Day of the Month", "No. of Days after End of Month","Day of Month after End of Month"};
	String[] astrTermVal    = {"0", "1", "2", "3", "4","5"};
	String[] astrDay = {"1st","2nd","3rd","4th","5th","6th","7th","8th","9th","10th","11th","12th","13th","14th","15th",
						"16th","17nd","18th","19th","20th","21th","22th","23th","24th","25th","26th","27th","28th","29th","30th",
						"31st","End of the month"};
	
	String strPageAction = WI.fillTextValue("pageAction");
	String strInfoIndex = WI.fillTextValue("info_index");
	if(strPageAction.length() > 0) {
		if(SUP.operateOnBuyingInfo(dbOP, request, Integer.parseInt(strPageAction)) == null){	
			strErrMsg = SUP.getErrMsg();
			}
		else {	
			if(strPageAction.equals("1"))
				strErrMsg = "Operation successful.";
		}
	}	  
	if (WI.fillTextValue("pageReloaded").length() == 0){
	   if (WI.fillTextValue("supplier_code").length() > 0){
		   vBuyingInfo = SUP.operateOnBuyingInfo(dbOP,request,4);
			 if (vBuyingInfo == null){
				strErrMsg = SUP.getErrMsg();
			 }else{
			 strInfoIndex = (String) vBuyingInfo.elementAt(17);
			 }		
		}else{
			strErrMsg = "Enter Supplier Code";
		}
	  }

%>
<body bgcolor="#D2AE72" onLoad="FocusSupplierCode();">
<form name="form_" method="post" action="suppliers_buying_info.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          PURCHASING - SUPPLIERS : BUYING INFORMATION PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="15" colspan="3"><%=WI.getStrValue(strErrMsg,"")%></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="196%" height="25" colspan="2">Supplier Code : 
        <input name="supplier_code" type="text" size="16" maxlength="128" value="<%=WI.fillTextValue("supplier_code")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a> 
        <a href="javascript:ProceedClicked();"> <img src="../../../images/form_proceed.gif" border="0">        </a></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
	  <% 
	    if (vBuyingInfo != null && vBuyingInfo.size() > 0){
	    	strTemp = (String) vBuyingInfo.elementAt(15);
		}else{
			 strTemp = "";
	    }  
	  %>
      <td height="25" colspan="2">Supplier Name : <strong><%=WI.getStrValue(strTemp," ")%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="15" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <%if ((vBuyingInfo != null && vBuyingInfo.size() > 0) || WI.fillTextValue("pageReloaded").length() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="2%" height="25">&nbsp;</td>
      <td height="25" colspan="2"><strong><u>ACCOUNT</u></strong></td>
      <td width="79%" height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td width="3%" height="25">&nbsp;</td>
      <td width="16%">Credit limit</td>	  
      <td height="25" colspan="2">
	  <% 
	    if ((vBuyingInfo != null && vBuyingInfo.size() > 0)){
	    	strTemp = (String) vBuyingInfo.elementAt(0);
		}else{
			 strTemp = WI.fillTextValue("credit_limit");
	    }  
	  %>
	  <input name="credit_limit" type="text" size="10" maxlength="10" value="<%=WI.getStrValue(strTemp,"")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Available Credit</td>
      <td height="25" colspan="2">
        <% 
	    if (vBuyingInfo != null && vBuyingInfo.size() > 0){
	    	strTemp = (String) vBuyingInfo.elementAt(1);
		}else{
			 strTemp = WI.fillTextValue("available_credit");
	    }  
	  %>
        <input name="available_credit" type="text" size="10" maxlength="10" value="<%=WI.getStrValue(strTemp,"")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Overdue </td>
      <td height="25" colspan="2">
        <% 
	    if (vBuyingInfo != null && vBuyingInfo.size() > 0){
	    	strTemp = (String) vBuyingInfo.elementAt(2);
		}else{
			 strTemp = WI.fillTextValue("overdue");
	    }  
	  %>
        <input name="overdue" type="text" size="10" maxlength="10"value="<%=WI.getStrValue(strTemp,"")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Expense Account</td>
      <td height="25" colspan="2">
        <% 
	    if (vBuyingInfo != null && vBuyingInfo.size() > 0){
	    	strTemp = (String) vBuyingInfo.elementAt(3);
		}else{
			 strTemp = WI.fillTextValue("expense_acct");
	    }  
	  %>
        <select name="expense_acct">
          <option value="">Select Type</option>
          <%=dbOP.loadCombo("ACCT_INDEX","ACCT_NAME"," from PUR_PRELOAD_EXP_ACCT order by ACCT_NAME", strTemp, false)%> 
        </select>
        <font size="1"><a href='javascript:viewList("PUR_PRELOAD_EXP_ACCT","ACCT_INDEX","ACCT_NAME","EXPENSE ACCOUNT",
		"PUR_SUP_BUYING_INFO","EXPENSE_ACCT","","","expense_acct")'><img src="../../../images/update.gif" border="0"></a>click 
        to update list of Expense account</font></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><strong><u>TAX INFO</u></strong></td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Tax ID Number</td>
      <td height="25" colspan="2">
        <% 
	    if (vBuyingInfo != null && vBuyingInfo.size() > 0){
	    	strTemp = (String) vBuyingInfo.elementAt(4);
		}else{
			 strTemp = WI.fillTextValue("tax_id");
	    }  
	  %>
        <input name="tax_id" type="text" size="16" maxlength="32" value="<%=WI.getStrValue(strTemp,"")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Tax Type</td>
      <td height="25" colspan="2">
        <% 
	    if (vBuyingInfo != null && vBuyingInfo.size() > 0){
	    	strTemp = (String) vBuyingInfo.elementAt(5);
		}else{
			 strTemp = WI.fillTextValue("tax_type");
	    }  
	  %>
        <font size="1">
        <select name="tax_type">
          <option value="">Select Type</option>
          <%=dbOP.loadCombo("TAX_INDEX","TAX_NAME"," from PUR_PRELOAD_TAX order by TAX_NAME", strTemp, false)%> 
        </select>
        <a href='javascript:viewList("PUR_PRELOAD_TAX","TAX_INDEX","TAX_NAME","TAX TYPE",
		"PUR_SUP_BUYING_INFO","TAX_TYPE","","","tax_type")'><img src="../../../images/update.gif" border="0"></a>click 
        to update list of Tax Type</font></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Freight Tax</td>
      <td height="25" colspan="2">
        <% 
	    if (vBuyingInfo != null && vBuyingInfo.size() > 0){
	    	strTemp = (String) vBuyingInfo.elementAt(6);
		}else{
			 strTemp = WI.fillTextValue("freight_tax");
	    }  
	  %>  
        <select name="freight_tax">
          <option value="">Select Type</option>
          <%=dbOP.loadCombo("TAX_INDEX","TAX_NAME"," from PUR_PRELOAD_TAX order by TAX_NAME", strTemp, false)%> 
        </select>
        <font size="1"><a href='javascript:viewList("PUR_PRELOAD_TAX","TAX_INDEX","TAX_NAME","TAX TYPE",
		"PUR_SUP_BUYING_INFO","TAX_TYPE","","","freight_tax")'><img src="../../../images/update.gif" border="0"></a>click 
        to update list of Tax Type</font></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">
        <% 
	    if (vBuyingInfo != null && vBuyingInfo.size() > 0){
	    	strTemp = (String) vBuyingInfo.elementAt(7);
		}else{
			 strTemp = WI.fillTextValue("supplier_tax");
	    }  
	  %>
	  	<%if (WI.getStrValue(strTemp,"0").equals("1")){%> 
		    <input type="checkbox" name="supplier_tax" value="1" checked> 
        <%} else {%> 
		    <input type="checkbox" name="supplier_tax" value="1"> 
        <%}%>
        Implement Supplier Tax Type</td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="2%" height="24">&nbsp;</td>
      <td height="24" colspan="4"><strong><u>PAYMENT TERMS</u></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td width="3%" height="25">&nbsp;</td>
      <td width="13%">Terms</td>
      <td width="82%" height="25" colspan="2"> <% 
	    if (vBuyingInfo != null && vBuyingInfo.size() > 0){
	    	strTerm = (String) vBuyingInfo.elementAt(8);
		}else{
			strTerm = WI.fillTextValue("credit_term");
	    }

		strTerm = WI.getStrValue(strTerm,"");
	  %> <select name="credit_term" onChange="ReloadPage();">
          <option value="" selected>Select Term</option>
          <%for (int i = 0; i<6 ; i++){%>
          <%if(WI.getStrValue(strTerm,"").equals(astrTermVal[i])){%>
          <option value="<%=astrTermVal[i]%>" selected><%=astrTerm[i]%></option>
          <%} else {%>
          <option value="<%=astrTermVal[i]%>"><%=astrTerm[i]%></option>
          <%}// end if%>
          <%}// for loop%>
        </select> </td>
    </tr>
    <%if (strTerm.equals("2") || strTerm.equals("3")){%>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Discount Days</td>
      <td height="25" colspan="2"><font size="1"> 
        <% 
	    if (vBuyingInfo != null && vBuyingInfo.size() > 0){
	    	strTemp = (String) vBuyingInfo.elementAt(9);
		}else{
			 strTemp = WI.fillTextValue("discount_days");
	    }  
	  %>
        <input name="discount_days" type="text" size="3" maxlength="3" value="<%=WI.getStrValue(strTemp,"")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </font></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Balance Due Days</td>
      <td height="25" colspan="2"><font size="1"> 
        <% 
	    if (vBuyingInfo != null && vBuyingInfo.size() > 0){
	    	strTemp = (String) vBuyingInfo.elementAt(10);
		}else{
			 strTemp = WI.fillTextValue("balance_due_day");
	    }  
	  %>
        <input name="balance_due_day" type="text" size="3" maxlength="3" value="<%=WI.getStrValue(strTemp,"")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </font></td>
    </tr>
    <%}else{%>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Discount Days</td>
      <td height="25" colspan="2"> 
	  <% 
	    if (vBuyingInfo != null && vBuyingInfo.size() > 0){
	    	strTemp = (String) vBuyingInfo.elementAt(9);
		}else{
			strTemp = WI.fillTextValue("discount_days");
	    }  
		strTemp = WI.getStrValue(strTemp,"");
	  %>
        <font size="1">
        <select name="discount_days">
          <option value="" selected>Select day</option>
          <%for (int i = 0; i<32 ; i++){%>
         	 <%if(strTemp.equals(Integer.toString(i))){%>
          		<option value="<%=i%>" selected><%=astrDay[i]%></option>
          	<%} else {%>
          		<option value="<%=i%>"><%=astrDay[i]%></option>
          	<%}// end if%>
          <%}// for loop%>
        </select>
        </font></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Balance Due Days</td>
      <td height="25" colspan="2"> <% 
	    if (vBuyingInfo != null && vBuyingInfo.size() > 0){
	    	strTemp = (String) vBuyingInfo.elementAt(10);
		}else{
			 strTemp = WI.fillTextValue("balance_due_day");
	    }
		strTemp = WI.getStrValue(strTemp,"");
	  %>
        <font size="1">
        <select name="balance_due_day">
          <option value="" selected>Select day</option>
          <%for (int i = 0; i<32 ; i++){%>
          <%if(strTemp.equals(Integer.toString(i))){%>
          <option value="<%=i%>" selected><%=astrDay[i]%></option>
          <%} else {%>
          <option value="<%=i%>"><%=astrDay[i]%></option>
          <%}// end if%>
          <%}// for loop%>
        </select>
        </font> </td>
    </tr>
    <%}%>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="24">&nbsp;</td>
      <td height="24">&nbsp;</td>
      <td height="24" colspan="3">% Discount for Early Payment : 
        <% 
	    if (vBuyingInfo != null && vBuyingInfo.size() > 0){
	    	strTemp = (String) vBuyingInfo.elementAt(11);
		}else{
			 strTemp = WI.fillTextValue("early_pay_disc");
	    }  
	  %> <input name="early_pay_disc" type="text" size="5" maxlength="5" value="<%=WI.getStrValue(strTemp,"")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">% Discount for Volume Purchase: 
        <% 
	    if (vBuyingInfo != null && vBuyingInfo.size() > 0){
	    	strTemp = (String) vBuyingInfo.elementAt(12);
		}else{
			 strTemp = WI.fillTextValue("volume_disc");
	    }  
	  %> <input name="volume_disc" type="text" size="5" maxlength="5" value="<%=WI.getStrValue(strTemp,"")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Purchase Comment : 
        <% 
	    if (vBuyingInfo != null && vBuyingInfo.size() > 0){
	    	strTemp = (String) vBuyingInfo.elementAt(13);
		}else{
			 strTemp = WI.fillTextValue("pur_comment");			 
	    }  		
	  %> <font size="1"> 
        <select name="pur_comment">
          <option value="">Select Type</option>
          <%=dbOP.loadCombo("COMMENT_INDEX","COMMENT"," from PUR_PRELOAD_COMMENT order by COMMENT", strTemp, false)%> 
        </select>
        <a href='javascript:viewList("PUR_PRELOAD_COMMENT","COMMENT_INDEX","COMMENT","PURCHASE COMMENT",
		"PUR_SUP_BUYING_INFO","PUR_COMMENT","","","pur_comment")'><img src="../../../images/update.gif" border="0"></a>click 
        to update Purchase Comment list</font></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Shipping Method : 
        <% 
	    if (vBuyingInfo != null && vBuyingInfo.size() > 0){
	    	strTemp = (String) vBuyingInfo.elementAt(14);
		}else{
			 strTemp = WI.fillTextValue("ship_method");
	    }  
	  %> <select name="ship_method">
          <option value="">Select Type</option>
          <%=dbOP.loadCombo("SHIPPING_INDEX","METHOD_NAME"," from PUR_PRELOAD_SHIPPING order by METHOD_NAME", strTemp, false)%> </select> <font size="1"><a href='javascript:viewList("PUR_PRELOAD_SHIPPING","SHIPPING_INDEX","METHOD_NAME","SHIPPING METHOD",
		"PUR_SUP_BUYING_INFO","SHIPPING_METHOD","","","ship_method")'><img src="../../../images/update.gif" border="0"></a>click 
        to update Shipping Method list </font></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
		<% if (vBuyingInfo != null && vBuyingInfo.size() > 0){
			strTemp = (String)vBuyingInfo.elementAt(17);
		}else{
			strTemp = WI.fillTextValue("info_index");
		}		
		//System.out.println("strTemp " + strTemp);
		%>
      <td height="37" colspan="5" align="center"> <font size="1"> <a href='javascript:PageAction(1,"<%=WI.getStrValue(strTemp,"")%>");'><img src="../../../images/save.gif" border="0"> 
        </a>click to save entries&nbsp; <a href="suppliers_buying_info.jsp"><img src="../../../images/cancel.gif" border="0"> 
      </a>click to cancel/clear entries </font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25">&nbsp;</td>
  </tr>
</table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="pageReloaded" value="">
  <input type="hidden" name="proceedClicked" value="">
  <input type="hidden" name="pageAction">
  <input type="hidden" name="info_index" value="<%=strInfoIndex%>"> 
  
</form>
</body>
</html>
<% 
dbOP.cleanUP();
%>