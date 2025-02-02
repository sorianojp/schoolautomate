<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function ReloadPage()
{	
	document.form_.print_page.value = "";
	document.form_.view_info.value = "1";
	document.form_.submit();
}

function PrintPg(){
	document.form_.print_page.value = "1";
	document.form_.submit();
}

</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAPayment,java.util.Vector" buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	
	if(WI.fillTextValue("print_page").length() > 0){%>
	<jsp:forward page="payment_modification_report_print.jsp"></jsp:forward>
	<%return;}
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Modifications","payment_modification.jsp");
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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
														"payment_modification.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

String[] astrDropListEqual = {"Equal To","Starts With","Ends With","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};

String[] astrSortByName    = {"Book Title","Author","Item Code"};
String[] astrSortByVal     = {"book_title","author","item_code"};


FAPayment faPayment = new FAPayment();
//enrollment.FAPaymentExtn faPayment = new enrollment.FAPaymentExtn();
ConstructSearch conSearch = new ConstructSearch();

Vector vRetResult =null;
int iElemCount = 0;
if(WI.fillTextValue("view_info").length() > 0){
	vRetResult = faPayment.generateModifiedOR(dbOP, request);
	if(vRetResult == null)
		strErrMsg = faPayment.getErrMsg();
	else
		iElemCount = faPayment.getElemCount();
}


  %>
<form name="form_" action="./payment_modification_report.jsp" method="post">

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          PAYMENT MODIFICATION REPORT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <a href="payment_modification_main.jsp"><img src="../../../images/go_back.gif" border="0"></a>
        Go to main page&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <% if(strErrMsg != null){%>
        <font size="3">Message: <strong><%=strErrMsg%></strong></font>
        <%}%>
      </td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
	<tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="20%">SY Term</td>
      <td width="76%" colspan="2"> 
<%
strTemp = WI.fillTextValue("sy_from");
if(WI.getStrValue(strTemp).length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'> 
<%
strTemp = WI.fillTextValue("sy_to");
if(WI.getStrValue(strTemp).length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        - 
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 
	  <select name="semester">
	  <option value=""></option>
	  <%=CommonUtil.constructTermList(dbOP, request, WI.fillTextValue("semester"))%>
        </select></td>
    </tr>
	<tr> 
      <td height="25">&nbsp;</td>
      <td>Date of Payment</td>
      <td colspan="2"><input name="date_fr" type="text" size="12" maxlength="12" readonly="yes" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
     
	  to
	  <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>	  </td>
    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Printed by</td>
	    <td colspan="2">
		<select name="printed_id_num_con">
				<%=conSearch.constructGenericDropList(WI.fillTextValue("printed_id_num_con"),astrDropListEqual,astrDropListValEqual)%> 
    	</select>
		<input name="printed_id_num" type="text" class="textbox" value="<%=WI.fillTextValue("printed_id_num")%>" maxlength="16"
					size="16" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'>		</td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Modified by</td>
	    <td colspan="2">
		<select name="modified_id_num_con">
				<%=conSearch.constructGenericDropList(WI.fillTextValue("modified_id_num_con"),astrDropListEqual,astrDropListValEqual)%> 
    	</select>
		<input name="modified_id_num" type="text" class="textbox" value="<%=WI.fillTextValue("modified_id_num")%>" maxlength="16"
					size="16" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'>		</td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Reason</td>
	    <td colspan="2"><select name="mod_reason_con">
				<%=conSearch.constructGenericDropList(WI.fillTextValue("mod_reason_con"),astrDropListEqual,astrDropListValEqual)%> 
    	</select>
		<input name="mod_reason" type="text" class="textbox" value="<%=WI.fillTextValue("mod_reason")%>" maxlength="16"
					size="16" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'></td>
	    </tr>
	<!--<tr>
	    <td height="25">&nbsp;</td>
	    <td>Payment for</td>
	    <td colspan="2">
		<select name="payment_for">
			<option value="0">Downpayment</option>
		</select>
		</td>
	    </tr>-->
	<tr>
          	<td height="25" width="4%">&nbsp;</td>
		  	<td width="20%">Sort by: </td>
		  	<td width="76%">
				<select name="sort_by1" style="width:100px">
					<option value="">N/A</option>
					<%=conSearch.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
				</select>
				<select name="sort_by2" style="width:100px">
              		<option value="">N/A</option>
             		<%=conSearch.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
				</select>
				<select name="sort_by3" style="width:100px">
					<option value="">N/A</option>
              		<%=conSearch.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
            	</select></td>
		</tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td colspan="2">
		<select name="sort_by1_con">
              		<option value="asc">Ascending</option>
              	<%if(WI.fillTextValue("sort_by1_con").equals("desc")){%>
              		<option value="desc" selected="selected">Descending</option>
              	<%}else{%>
              		<option value="desc">Descending</option>
              	<%}%>
				</select>
				
				<select name="sort_by2_con">
              		<option value="asc">Ascending</option>
              	<%if(WI.fillTextValue("sort_by2_con").equals("desc")){%>
              		<option value="desc" selected="selected">Descending</option>
              	<%}else{%>
              		<option value="desc">Descending</option>
              	<%}%>
				</select>
				
				<select name="sort_by3_con">
              		<option value="asc">Ascending</option>
              	<%if(WI.fillTextValue("sort_by3_con").equals("desc")){%>
              		<option value="desc" selected="selected">Descending</option>
              	<%}else{%>
              		<option value="desc">Descending</option>
              	<%}%>
				</select>		</td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td colspan="2"><a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a></td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td colspan="2">&nbsp;</td>
	    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){
%>  
 <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="13" >
	  
	  <div align="right">
	  Rows Per Page: 
	  <select name="rows_per_pg">
<%
int iDefVal = 35;
if(WI.fillTextValue("rows_per_pg").length() > 0)
	iDefVal = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
for(int i = 25; i < 70; ++i) {
	if(iDefVal == i)
		strTemp = " selected";
	else	
		strTemp = "";
%>
	<option value="<%=i%>" <%=strTemp%>><%=i%></option>
<%}%>
	  </select>
	&nbsp; &nbsp;
	  <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to print list</font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="13" bgcolor="#B9B292"><div align="center"><strong>LIST OF MODIFIED PAYMENT</strong></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr align="center"> 
      <td width="6%" height="25"><div align="center"><font size="1"><strong>OR. NO.</strong></font></div></td>
      <td width="6%"><font size="1"><strong>Student ID</strong></font></td>
      <td width="8%"><font size="1"><strong>Student Name</strong></font></td>
      <td width="8%"><div align="center"><font size="1"><strong>SY (TERM)</strong></font></div></td>
      <td width="9%"><div align="center"><font size="1"><strong>AMOUNT</strong></font></div></td>
      <td width="11%"><div align="center"><font size="1"><strong>OR PRINTED BY</strong></font></div></td>
      <td width="8%"><div align="center"><font size="1"><strong>TRANSACTION DATE</strong></font></div></td>
      <td width="8%"><div align="center"><font size="1"><strong>PAYMENT FOR </strong></font></div></td>
      <td width="13%"><div align="center"><font size="1"><strong>REASON FOR MODIFICATION</strong></font></div></td>
      <td width="11%"><font size="1"><strong>MODIFIED BY</strong></font></td>      
	  <td width="12%"><font size="1"><strong>DATE MODIFIED</strong></font></td>      
    </tr>
    <%
 for(int i = 0; i < vRetResult.size(); i += iElemCount) {%>
    <tr> 
      <td height="25"><%=vRetResult.elementAt(i)%></td>
      <td><%=vRetResult.elementAt(i+1)%></td>
	  <%
	  strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),4);
	  %>
      <td><%=strTemp%></td>
	  <%
	  strTemp = (String)vRetResult.elementAt(i + 5)+"-"+(String)vRetResult.elementAt(i + 6)+
		  	WI.getStrValue((String)vRetResult.elementAt(i + 7),"(",")","");
	  %>
      <td><%=strTemp%></td>
      <td><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 8),true)%></td>
      <td><%=vRetResult.elementAt(i+9)%></td>
      <td><%=vRetResult.elementAt(i+13)%></td>
      <td><%=vRetResult.elementAt(i+15)%></td>
      <td><%=vRetResult.elementAt(i+16)%></td>
      <td><%=vRetResult.elementAt(i+17)%></td>      
	  <td><%=vRetResult.elementAt(i+14)%></td>      
    </tr>
    <%}%>
  </table>
<%}%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="view_info" value="">
<input type="hidden" name="print_page" >


</form>
</body>
</html>
<%
dbOP.cleanUP();
%>