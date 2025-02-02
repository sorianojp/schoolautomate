<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strAction,strIndex){
	if(strAction == 0){
		if(!confirm('Are you sure you want to remove this information and all chart of account information attached to it.'))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strIndex;
	document.form_.submit();
}
function PreparedToEdit(strIndex) {
	document.form_.info_index.value = strIndex;
	document.form_.preparedToEdit.value = "1";
	document.form_.page_action.value = "";
	document.form_.submit();
}
function ViewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function UpdateCOA(strTBIndex) {
	var loadPg = "./setup_coa.jsp?tb_ref="+strTBIndex;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=750,height=600,top=50,left=50,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
	
}

</script>
<%@ page language="java" import="utility.*,Accounting.Administration,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Administration-Set up trial balance-setup","setup.jsp");
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
														"Accounting","Administration",request.getRemoteAddr(), 
														"setup.jsp");	
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");
Vector vRetResult = null; Vector vEditInfo = null;

Administration adminTB = new Administration();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(adminTB.operateOnTB(dbOP, request, Integer.parseInt(strTemp)) == null) 
		strErrMsg = adminTB.getErrMsg();
	else {
		strErrMsg = "Operation successful.";
		strPreparedToEdit = "0";
	}
}	

if(strPreparedToEdit.equals("1"))
	vEditInfo = adminTB.operateOnTB(dbOP, request, 3);

vRetResult = adminTB.operateOnTB(dbOP, request, 4);

%>
<form name="form_" method="post" action="setup.jsp" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0">
    <tr> 
      <td colspan="3" style="font-size:14px; color:#FF0000; font-weight:bold">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    
    <tr>
      <td>&nbsp;</td>
      <td style="font-size:10px;">Report Name </td>
      <td>
	  <select name="report_ref" onChange="document.form_.page_action.value='';document.form_.preparedToEdit.value='';document.form_.submit();">
<%
strTemp = dbOP.loadCombo("REPORT_REF","REPORT_NAME", " from AC_SET_TB_REPORT order by REPORT_NAME",WI.fillTextValue("report_ref"),false);
if(strTemp.length() == 0) 
	strTemp = "<option></option>";
%>
          <%=strTemp%> 
        </select> <a href='javascript:ViewList("AC_SET_TB_REPORT","REPORT_REF","REPORT_NAME","REPORT NAME","AC_SET_TB","REPORT_INDEX", " and TB_INDEX > 0","","report_ref")'> 
        <img src="../../../../images/update.gif" border="0"></a> 
	  &nbsp;&nbsp;&nbsp;
	    <input type="submit" name="122" value="Reload Page" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value=''; document.form_.preparedToEdit.value=''"></td>
    </tr>
<%if(WI.fillTextValue("report_ref").length() > 0) {%>
    <tr> 
      <td width="2%">&nbsp;</td>
      <td width="20%" style="font-size:10px;">Trial Balance Name </td>
      <td width="78%">
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("tb_name");
%>
<input type="text" name="tb_name" class="textbox" value="<%=WI.getStrValue(strTemp)%>"  maxlength="96" size="32"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td valign="top" style="font-size:10px;">
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("is_debit");
if(strTemp.equals("1")) {
	strTemp = " checked";
	strErrMsg = "";
}
else {
	strTemp = "";
	strErrMsg = " checked";
}
%>
	  <input name="is_debit" type="radio" value="1" <%=strTemp%>> Debit
	  <input name="is_debit" type="radio" value="0" <%=strErrMsg%>> Credit	  </td>
      <td style="font-size:10px;">Order Number : 
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("order_no");
int iTemp = Integer.parseInt(WI.getStrValue(strTemp, "0"));
%>	
		<select name="order_no">
		<%for(int i = 1; i < 254; ++i) {
			if(iTemp == i)
				strTemp = "selected";
			else
				strTemp = "";
		%>
		<option value="<%=i%>" <%=strTemp%>><%=i%></option>
		<%}%>
		</select></td>
    </tr>
    <tr> 
      <td colspan="3"><hr size="1"></td>
    </tr>
  </table>
	  
  <table width="100%" border="0">
    <tr valign="top"> 
      <td width="2%">&nbsp;</td>
      <td width="20%" style="font-size:10px;">&nbsp;</td>
      <td width="78%">&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>
	  <%if(iAccessLevel > 1 && strPreparedToEdit.equals("0")) {%>
        <input type="submit" name="12" value="Save Information" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='1'">
      <%}else if(iAccessLevel > 1){%>
        <input type="submit" name="1" value="Edit Information" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='2';document.form_.info_index.value=<%=vEditInfo.elementAt(0)%>">
		&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="submit" name="1" value="Cancel Edit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='';document.form_.preparedToEdit.value='';document.form_.date_taken.value='';document.form_.license_no.value='';document.form_.remarks.value=''">
	  <%}%>	  </td>
    </tr>
<%}//show only if report ref length > 0%>    
    <tr> 
      <td colspan="3">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="25" colspan="7" bgcolor="#B9B292" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>:: LIST OF TRIAL BALANCE ACCOUNT NAME FOR REPORT ::
	  <br>
	  <%=WI.fillTextValue("tb_report_name")%>
	   </strong></font></div></td>
    </tr>
    <tr>
      <td width="5%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">ORDER # </td> 
      <td width="25%" height="25" align="center" style="font-size:9px; font-weight:bold" class="thinborder">TRIAL BALANCE</td>
      <td width="40%" align="center" style="font-size:9px; font-weight:bold" class="thinborder"><span class="thinborder" style="font-size:9px; font-weight:bold">ACCOUNT #</span></td>
      <td width="5%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">C/D</td>
      <td width="10%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">UPDATE COA</td>
      <td width="7%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">&nbsp;</td>
      <td width="8%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">&nbsp;</td>
    </tr>
<%String[] astrConvertCD = {"C","D"};
for(int i = 0; i < vRetResult.size(); i += 5){%>
    <tr>
      <td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td> 
      <td height="25" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 4), "Not Set")%></td>
      <td class="thinborder" style="font-size:14px; font-weight:bold" align="center"><%=astrConvertCD[Integer.parseInt((String)vRetResult.elementAt(i + 2))]%></td>
      <td class="thinborder" align="center"><a href="javascript:UpdateCOA('<%=vRetResult.elementAt(i)%>')"><img src="../../../../images/update.gif" border="0"></a></td>
      <td class="thinborder">
		<%if(iAccessLevel > 1){%>
		  	<a href="javascript:PreparedToEdit('<%=vRetResult.elementAt(i)%>');">Edit</a>
		<%}else{%>&nbsp;<%}%>      </td>
      <td class="thinborder">
		<%if(iAccessLevel == 2){%>
			<a href="javascript:PageAction('0','<%=vRetResult.elementAt(i)%>');">Remove</a>
		 <%}else{%>&nbsp;<%}%>	  </td>
    </tr>
<%}%>
  </table>
<%}%>  


  <input type="hidden" name="page_action">
  <input type="hidden" name="info_index">
  <input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
  
</form>
</body>
</html>
<% 
dbOP.cleanUP();
%>