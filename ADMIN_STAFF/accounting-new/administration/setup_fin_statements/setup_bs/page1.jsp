<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function PageAction(strAction,strIndex){
	if(strAction == 0){
		if(!confirm('Are you sure you want to remove this information.'))
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
function GoToPage2(strBSIndex) {
	var loadPg = "./page2.jsp?bs_main_ref="+strBSIndex;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=800,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72">
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
								"Admin/staff-Accounting-Administration-Set up balance sheet","page1.jsp");
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
														"page1.jsp");	
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
	
	Administration admin = new Administration();	
	Vector vRetResult        = null;
	Vector vEditInfo         = null;
	
	String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"),"0");
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(admin.operateOnBalanceSheetPage1(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = admin.getErrMsg();
		else {
			strErrMsg = "Balance Sheet set up infomration updated successfully.";	
			strPreparedToEdit = "0";
		}
	}
	vRetResult = admin.operateOnBalanceSheetPage1(dbOP, request, 4);
	if(strPreparedToEdit.equals("1"))
		vEditInfo = admin.operateOnBalanceSheetPage1(dbOP, request, 3);
%>
	

<form name="form_" method="post" action="page1.jsp" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B5AB73"> 
      <td width="131%" height="27" colspan="8" bgcolor="#B5AB73" align="center" style="font-weight:bold; color:#FFFFFF">:::: SETUP FOR BALANCE SHEET REPORT PAGE ::::</td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="3" style="font-size:14px; color:#FF0000; font-weight:bold">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr> 
      <td width="4%">&nbsp;</td>
      <td width="19%">Group Title</td>
      <td width="77%">
	  
	  <select name="coa_cf">
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(7);
else	
	strTemp = WI.fillTextValue("coa_cf");
%>
<%=dbOP.loadCombo("COA_CF","CF_NAME"," from AC_COA_CF order by COA_CF asc",strTemp, false)%>
      </select> </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Sub-Group Order</td>
      <td> 
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("sg_order");

int iTemp = Integer.parseInt(WI.getStrValue(strTemp, "0"));	
String[] astrConvertToChar = {"","A","B","C","D","E","F","G","H"};
%>
	  <select name="sg_order">
<%for(int i = 1; i < 9; ++i) {
	if(i == iTemp)
		strTemp = " selected";
	else	
		strTemp = "";
%>
		<option value="<%=i%>"<%=strTemp%>><%=astrConvertToChar[i]%></option>
<%}%>
        </select> </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Sub-Group </td>
      <td>
	  <select name="sg_index">
<%
if(vEditInfo != null)
	strErrMsg = (String)vEditInfo.elementAt(3);
else
	strErrMsg = WI.fillTextValue("sg_index");
	
strTemp = dbOP.loadCombo("SG_PRELOAD_INDEX","SG_NAME"," FROM AC_SET_BS_SUB_PRELOAD order by SG_NAME", strErrMsg, false);
if(strTemp.length() > 0){%>
	<%=strTemp%>
<%}else{%>
	<option value=""></option>
<%}%>			
      </select> &nbsp;&nbsp;&nbsp;&nbsp; 
	<a href='javascript:ViewList("AC_SET_BS_SUB_PRELOAD","SG_PRELOAD_INDEX","SG_NAME","Sub-Group Name",
							       "AC_SET_BS_MAIN","SG_INDEX", 
			                       " and is_valid=1 ","","sg_index")'>	  
	  <img src="../../../../../images/update.gif" border="0"></a>
	  <font size="1">Click to update list of Sub-Group</font></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Sub-Group Items</td>
      <td> 
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("sg_item_order");

iTemp = Integer.parseInt(WI.getStrValue(strTemp, "0"));	
%>
	  <select name="sg_item_order">
<%for(int i = 1; i < 9; ++i) {
	if(i == iTemp)
		strTemp = " selected";
	else	
		strTemp = "";
%>
		<option value="<%=i%>"<%=strTemp%>><%=i%></option>
<%}%>
        </select>
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("sg_item_name");
%>
	  <input type="text" name="sg_item_name" class="textbox" value="<%=WI.getStrValue(strTemp)%>"  maxlength="96" size="32"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  </td>
    </tr>
    <%
if(iAccessLevel ==2){%>
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
<%}%></td>
    </tr>
    <%}%>
    <tr> 
      <td colspan="3">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null){%>  
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="5" bgcolor="#B9B292" class="thinborder" align="center"><font color="#FFFFFF"><strong>:: TITLES/NAME TO APPEAR IN BALANCE SHEET :: </strong></font></td>
    </tr>
    <tr> 
      <td width="14%" class="thinborder" align="center"><font size="1"><strong>GROUP TITLE</strong></font></td>
      <td width="6%" height="25" class="thinborder" align="center"><font size="1"><strong>SUB-GROUP ORDER </strong></font></td>
      <td width="30%" class="thinborder" align="center"><strong><font size="1">SUB-GROUP NAME</font></strong></td>
      <td width="7%" class="thinborder" style="font-weight:bold; font-size:9px;"  align="center">UPDATE</td>
      <td width="43%" align="center" class="thinborder"><strong><font size="1">SUB-GROUP ITEMS</font></strong></td>
    </tr>
<%
for(int i = 0 ; i < vRetResult.size(); i += 8) {%>
    <tr> 
      <td class="thinborder">
	  <%if(i == 0 || !vRetResult.elementAt(i + 1).equals(vRetResult.elementAt(i + 1 - 8)) ){%>
	  	<%=vRetResult.elementAt(i + 1)%>
	  <%}else{%>&nbsp;<%}%></td>
      <td class="thinborder"><%=astrConvertToChar[Integer.parseInt((String)vRetResult.elementAt(i + 2))]%></td>
      <td height="25" class="thinborder"><%=vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder">
	  <a href="javascript:GoToPage2('<%=vRetResult.elementAt(i)%>');">
	  	<img src="../../../../../images/update.gif" border="0"></a>
	  </td>
      <td class="thinborder">
	  	<table width="100%" cellpadding="0" cellspacing="0">
			<%while(i < vRetResult.size()){%>
			<tr bgcolor="#FFFFCC">
				<td style="font-size:9px; font-weight:bold" width="60%"><%=WI.getStrValue(vRetResult.elementAt(i + 5),"-")%></td>
				<td style="font-size:9px;" width="20%">
					<%if(iAccessLevel > 1){%>
		  			<a href="javascript:PreparedToEdit('<%=vRetResult.elementAt(i)%>');">Edit</a>
				    <%}else{%>&nbsp;<%}%></td>
				<td style="font-size:9px;" width="20%">
				<%if(iAccessLevel == 2){%>
			  	<a href="javascript:PageAction('0','<%=vRetResult.elementAt(i)%>');">Remove</a>
		  		<%}else{%>&nbsp;<%}%>
				</td>
			</tr>
			<%i += 8;
			if(i < vRetResult.size() && !vRetResult.elementAt(i - 8 + 3).equals(vRetResult.elementAt(i + 3)))
				break;} i -= 8;%>
		</table>	  
		</td>
    </tr>
<%}%>
  </table>
<%}//show only if vRetResult is not null. %>
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr> 
      <td height="25" bgcolor="#FFFFFF" >&nbsp;</td>
    </tr>
    <tr>
      <td height="27" bgcolor="#B5AB73">&nbsp;</td>
    </tr>
  </table>


  <input type="hidden" name="page_action">
  <input type="hidden" name="info_index">
  <input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
</form>
</body>
</html>
<% 
dbOP.cleanUP();
%>