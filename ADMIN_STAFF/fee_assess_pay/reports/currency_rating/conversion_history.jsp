<%@ page language="java" import="utility.*,java.util.Vector, locker.Currency " %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<link href="../../../../css/tabStyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

    TABLE.thinborderALL {
    border-top: solid 1px #FFFFFF;
    border-left: solid 1px #FFFFFF;
    border-right: solid 1px #FFFFFF;
    border-bottom: solid 1px #FFFFFF;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

</style>

<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../../css/frontPageLayout.css" rel="stylesheet" type="text/css" />
<script language="javascript" src="javascripts/Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/formatFloat.js"></script>
<script language="javascript">	
	
	function PageAction(strAction, strInfoIndex) {		
		document.form_.print_pg.value="";
		document.form_.page_action.value = strAction;
		if(strAction == '0') {
			if(confirm("Are you sure you want to delete this record?")){
				document.form_.page_action.value ='0';								
			}	
		}
		document.form_.info_index.value = strInfoIndex;		
		document.form_.submit();
	}
	
	function PrepareToEdit(strInfoIndex) {
		document.form_.print_pg.value="";
		document.form_.page_action.value ='';
		document.form_.prepareToEdit.value ='1';
		
		document.form_.info_index.value = strInfoIndex;	
		document.form_.submit();
	}
	function ReloadPage(){
		document.form_.page_action.value ='';
		document.form_.prepareToEdit.value ='';
			document.form_.print_pg.value="";
		document.form_.info_index.value = '';
		document.form_.submit();
	}	
	
function CancelRecord(){
	location = "conversion_history.jsp";
}	

function PrintPg(){
 	document.form_.print_pg.value="1";
	this.SubmitOnce("form_");
}
</script>
</head>
<%
	DBOperation dbOP  = null;
	WebInterface WI   = new WebInterface(request);
	Vector vRetResult = null;
	Vector vEditInfo  = null;
	//add security here.
if (WI.fillTextValue("print_pg").length() > 0){ %>
	<jsp:forward page="./conversion_history_print.jsp" />
<% return;}
//add security here.

	String strErrMsg  		 = null;
	String strTemp    		 = null;
	String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"), "0");
		
	Currency currency = new Currency();	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("Fee Assessment & Payments".toUpperCase()),"0"));
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("Fee Assessment & Payments-Reports".toUpperCase()),"0"));
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
	try{
		dbOP = new DBOperation();
	}catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0 ) {		
		if( currency.operateOnConvertionHistory(request,dbOP, Integer.parseInt(strTemp)) == null)
			strErrMsg = currency.getErrMsg();
		else {	
			strErrMsg = "Operation Successful.";
			strPreparedToEdit = "0";
			vEditInfo = null;
		}
	}

	int iSearchResult = 0;
	int i = 0;
	if(strPreparedToEdit.equals("1")){		
		vEditInfo = currency.operateOnConvertionHistory(request,dbOP, 3);
		if(vEditInfo == null)
			strErrMsg = currency.getErrMsg();
	}	
	
	vRetResult = currency.operateOnConvertionHistory(request,dbOP, 4);
	if(vRetResult == null && strErrMsg == null) 
		strErrMsg = currency.getErrMsg();
		
	if(vRetResult != null)
		iSearchResult = currency.getSearchCount();
	
	
	//System.out.println("vRetResult after display: " + vRetResult );
		
%>
<body>
<form name="form_" method="post" action="conversion_history.jsp">
  <table border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2">
	  <jsp:include page="./inc.jsp?pgIndex=2"></jsp:include>
	  </td>
    </tr>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
        CURRENCY CONVERSION HISTORY PAGE ::::</strong></font></td>
    </tr>    
		<tr bgcolor="#FFFFFF">
      <td height="30"><font size="1">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg,"")%></font></font></td>
    </tr>	
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">		
	<tr>
	  <td >&nbsp;</td>
	  <td >Select Currency</td>
	  <td ><%if(vEditInfo != null && vEditInfo.size() > 0)		
				strTemp = (String)vEditInfo.elementAt(1);		
			else
				strTemp = WI.fillTextValue("new_curr_name");			
			%>
      <select name="new_curr_name">
        <%=dbOP.loadCombo("currency_index", "name", " from fa_currency_type ",strTemp, false)%>
      </select></td>
	  </tr>
	<tr>
	  <td >&nbsp;</td>
	  <td >Amount</td>
	  <td ><%if(vEditInfo != null && vEditInfo.size() > 0)		
				strTemp = (String)vEditInfo.elementAt(3);		
			else
				strTemp = WI.fillTextValue("amount_val");			
			%>
	    <input name="amount_val" type="text" size="10" value="<%=WI.getStrValue(strTemp)%>" 
			class="textbox" onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','amount_val');style.backgroundColor='white'" 
			onKeyUp="AllowOnlyFloat('form_','amount_val');" 
			maxlength="8" style="text-align:right"></td>
	  </tr>
	<tr>
	  <td width="2%" >&nbsp;</td>
	  <td width="17%" >Conversion Date</td>
	  <td width="81%" ><%if(vEditInfo != null && vEditInfo.size() > 0)		
				strTemp = (String)vEditInfo.elementAt(2);		
			else
				strTemp = WI.fillTextValue("conv_date");			
			if(strTemp.length() == 0)
				strTemp = WI.getTodaysDate(1);
			%>
	    <input name="conv_date" type="text" size="10" maxlength="10"
			  value="<%=WI.getStrValue(strTemp)%>" class="textbox"			  
			  onfocus="style.backgroundColor='#D3EBFF'"
			  onblur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','conv_date','/')" />
      <a href="javascript:show_calendar('form_.conv_date');" title="Click to select date" 
						onmouseover="window.status='Select date';return true;" 
						onmouseout="window.status='';return true;"> <img src="../../../../images/calendar_new.gif" border="0" /></a></td>
	  </tr>
	<tr>
	  <td height="21" >&nbsp;</td>
	  <td >&nbsp;</td>
	  <td >&nbsp;</td>
	  </tr>
	<tr>
	  <td >&nbsp;</td>
	  <td >&nbsp;</td>
	  <td ><%if(strPreparedToEdit.compareTo("1") != 0) {%>
      <input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onclick="javascript:PageAction('1', '');" />
      <font size="1">click to save entries</font>
      <%}else{%>
      <input type="button" name="edit" value=" Edit " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onclick="PageAction('2','<%=(String)vEditInfo.elementAt(0)%>');" />
      <font size="1"> click to save changes</font>
      <%}%>
      <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onclick="javascript:CancelRecord();" />
      <font size="1"> click to clear fields </font></td>
	  </tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
	<tr>
	  <td colspan="6"><hr size="1"></td>
	  </tr>
	<tr>
	  <td height="23">&nbsp;</td>
	  <td colspan="3">View Option </td>
	  <td colspan="2">&nbsp;</td>
	  </tr>
	<tr>
	  <td width="2%" height="29">&nbsp;</td>
	  <td colspan="3"> Inclusive dates </td>
	  <td width="82%" colspan="2">From
      <input name="from_date" type="text" size="10" maxlength="10"
			  value="<%=WI.fillTextValue("from_date")%>" class="textbox"			  
			  onfocus="style.backgroundColor='#D3EBFF'"
			  onblur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','from_date','/')" />
      <a href="javascript:show_calendar('form_.from_date');" title="Click to select date" 
						onmouseover="window.status='Select date';return true;" 
						onmouseout="window.status='';return true;"> <img src="../../../../images/calendar_new.gif" border="0" /> </a> To
      <input name="to_date" type="text" size="10" maxlength="10"
				value="<%=WI.fillTextValue("to_date")%>" class="textbox"
				onfocus="style.backgroundColor='#D3EBFF'"				
				onblur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','to_date','/')" />
      <a href="javascript:show_calendar('form_.to_date');" title="Click to select date" 
						onmouseover="window.status='Select date';return true;"
						onmouseout="window.status='';return true;"> <img src="../../../../images/calendar_new.gif" border="0" /> </a></td>
	  </tr>
	<tr>
	  <td height="28">&nbsp;</td>
		<td colspan="3"> Currency Name </td>
		<td colspan="2"><select name="curr_name">
      <option value="">Display All</option>
      <%=dbOP.loadCombo("currency_index", "name", " from fa_currency_type ",WI.fillTextValue("curr_name"), false)%>
    </select></td>
	</tr>	
	
	<tr>
	  <td>&nbsp;</td>
	  <td height="19" colspan="3">&nbsp;</td>
	  <td colspan="4">&nbsp;</td>
	  </tr>
	<tr>
	  <td>&nbsp;</td>
		<td colspan="3">&nbsp;</td>
		<td colspan="4">
		<input type="button" value="Search" onclick="ReloadPage();" 
		style="font-size:11px; height:26px;border: 1px solid #FF0000;" >	  </td>
	</tr>	
	<tr><td colspan="9" ><hr /></td></tr> <!-- Line separator  -->
  </table>	
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>   
      <% if (vRetResult != null && vRetResult.size() > 0 ){%>
      <td height="10"><div align="right"><font size="2">Number of  rows Per 
        Page :</font><font>
                  <select name="num_rec_page">
                    <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(i = 10; i <=40 ; i++) {
				if ( i == iDefault) {%>
                    <option selected value="<%=i%>"><%=i%></option>
                    <%}else{%>
                    <option value="<%=i%>"><%=i%></option>
                    <%}}%>
                  </select>
                  <a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> <font size="1">click to print</font></font></div></td>
      <%}%>
    </tr>
    <%if(WI.fillTextValue("view_all").length() == 0){
	int iPageCount = iSearchResult/currency.defSearchSize;		
	if(iSearchResult % currency.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>
    <tr>
      <td><div align="right"><font size="2">Jump To page:
        <select name="jumpto" onChange="ReloadPage();">
      <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i = 1; i <= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
                  <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
                  <%}else{%>
                  <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
                  <%
					}
			}
			%>
          </select>
      </font></div></td>
    </tr>
    <%} // end if pages > 1
		}// end if not view all%>
  </table>	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">	
	<%if(vRetResult != null && vRetResult.size() > 0){%>
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="6" align="center" class="thinborder"><font color="#FFFFFF"><strong>Conversion History </strong></font></td>
    </tr>	
	<tr align="center">
		<td width="12%" height="21" class="thinborder"><strong>Date </strong></td>
		<td width="22%" class="thinborder"><strong>Currency</strong></td>
		<td width="15%" class="thinborder"><strong>Amount</strong></td>
		<td width="33%" class="thinborder"><strong>Created by</strong></td>
		<td width="18%" colspan="2" class="thinborder"><strong>Options</strong></td>		
	</tr>
	<%for(i = 0; i < vRetResult.size(); i += 9){%>
		<tr bgcolor="#FFFFF0">			
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td align="right" class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+2),true)%>&nbsp;</td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+6)%></td>					
			<td  colspan="2" align="center" class="thinborder">					
				<input type="button" name="editBtn" value=" EDIT "
				onclick = "PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');" 					
				style="font-size:11px; height:26px;border: 1px solid #FF0000;" />
				
			&nbsp;
			<input type="button" name="deleteBtn" value="DELETE"
			onclick = "PageAction('0','<%=(String)vRetResult.elementAt(i)%>');" 
			style="font-size:11px; height:26px;border: 1px solid #FF0000;" /></td>
	<%}}%> <!-- end of for loop and if -->
</table>

	<!-- Table for dispalying the information
	<div id="currHisttable" name="currHisttable" ></div> -->
	<input type="hidden" name="print_pg">
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPreparedToEdit%>">
</form>
</body>
</html>

<%
if(dbOP!=null)
	dbOP.cleanUP();
%>

