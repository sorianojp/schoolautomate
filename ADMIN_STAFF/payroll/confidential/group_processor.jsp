<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRConfidential"%>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
///added code for HR/companies.
boolean bolPopUp = false;
String strReadOnly = "";
if(WI.fillTextValue("popup").length() > 0){
	bolPopUp = true;
	strReadOnly = " readonly";
}

boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Processor</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function checkAllSave() {
	var maxDisp = document.form_.emp_count.value;
	//unselect if it is unchecked.
	if(!document.form_.selAllSave.checked) {
		for(var i =0; i< maxDisp; ++i)
			eval('document.form_.delete_'+i+'.checked=false');
	}
	else {
		for(var i =0; i< maxDisp; ++i)
			eval('document.form_.delete_'+i+'.checked=true');
	}
}
 
function ReloadPage()
{
 	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function viewList(table,indexname,colname,labelname,tablelist, 
									strIndexes, strExtraTableCond,strExtraCond,
									strFormField){
//	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+labelname+
//	"&opner_form_name=form_";
	//document.form_.donot_call_close_wnd.value="0";
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
 

//all about ajax - to display student list with same name.
function AjaxMapName() {
	var strCompleteName = document.form_.emp_id.value;
	var objCOAInput = document.getElementById("coa_info");
	
	if(strCompleteName.length <=2) {
		objCOAInput.innerHTML = "";
		return ;
	}

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
} 

function focusID() {		
	document.form_.emp_id.focus();
}

function AddRecord(){
	document.form_.page_action.value = "1";
	document.form_.submit();
//	this.SubmitOnce("form_");
}

function DeleteRecord(){
	document.form_.page_action.value = "0";
	document.form_.submit();
//	this.SubmitOnce("form_");
}

function CancelRecord(){
	location = "./group_processor.jsp";
}
</script>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
   //add security here.
 
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-CONFIGURATION-Payroll Processor","group_processor.jsp");

	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0){
iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","CONFIGURATION-GS",request.getRemoteAddr(),
														null);
}
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
 Vector vRetResult = null;
  
PRConfidential prCon = new PRConfidential();
int iCount = 0;
String strPageAction = WI.fillTextValue("page_action");
int iSearchResult = 0;

if(strPageAction.length() > 0){
	vRetResult = prCon.operateOnGroupProcessor(dbOP, request, Integer.parseInt(strPageAction));
	if(vRetResult == null)
		strErrMsg = prCon.getErrMsg();
}

	vRetResult = prCon.operateOnGroupProcessor(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = prCon.getErrMsg();
	else
		iSearchResult = prCon.getSearchCount(); 
%>
<body bgcolor="#D2AE72" onLoad="focusID();" class="bgDynamic">
<form action="group_processor.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
        PAYROLL :  ASSIGNING EMPLOYEE TO PROCESS PAYROLL PAGE ::::</strong></font></td>
    </tr>
</table>	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">		
    <tr>
      <td height="23" colspan="3"><strong><font size="3"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
    </tr>
    
    <tr>
      <td width="20" height="10">&nbsp;</td>
      <td width="132">Employee ID :      </td>
 		  <td width="594">
			<input name="emp_id" type="text" class="textbox" onKeyUp="AjaxMapName()"
	    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>" size="16">
			<label id="coa_info"></label>			</td>
    </tr>

    <tr>
      <td height="10">&nbsp;</td>
      <td>Group to Process : </td>
      <td><select name="group_index">
        <option value="">Select Group</option>
        <%=dbOP.loadCombo("group_index","group_name"," from pr_preload_group order by group_name", WI.fillTextValue("group_index"), false)%>
      </select>
			<!--
			function viewList(table, indexname, colname, labelname, tablelist, 
									strIndexes, strExtraTableCond, strExtraCond, strFormField)
			-->
			<%if(iAccessLevel > 1){%>
        <a href='javascript:viewList("pr_preload_group","group_index","group_name",
																		 "Employee Groupings", "pr_emp_group, pr_group_proc", 
																		 "group_index, group_index",
																		 " and user_index is not null,  and user_index is not null",
																		 "","group_index");'><img src="../../../images/update.gif" border="0" ></a>
																		 
			<%}%></td>
    </tr>
		
    <tr>
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td><%
				if(WI.fillTextValue("view_all").length() > 0){
					strTemp = " checked";				
				} else {
					strTemp = "";
				}
			%>
        <input name="view_all" type="checkbox" value="1"<%=strTemp%> onClick="ReloadPage();">
View ALL </td>
    </tr>
    <tr>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td colspan="2" align="center">
			<%if(iAccessLevel > 1){%>
			<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:AddRecord();">
        <font size="1">click to add</font>
        <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:CancelRecord();">
        <font size="1">click to cancel</font>
			<%}%>
			</td>
    </tr>
    <tr>
      <td height="10" colspan="3"><hr size="1"></td>
    </tr> 
  </table>
	<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">    	
  <tr>
    <td align="right"><%
		if(!WI.fillTextValue("view_all").equals("1")){
		int iPageCount = iSearchResult/prCon.defSearchSize;
		if(iSearchResult % prCon.defSearchSize > 0) ++iPageCount;		
		if(iPageCount > 1)
		{%>
Jump To page:
  <select name="jumpto" onChange="ReloadPage();">
    <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
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
  <%}
				}%></td>
  </tr>
</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">    	
    <tr bgcolor="#B9B292" class="thinborder"> 
      <td height="23" colspan="4" align="center"><b>LIST OF EMPLOYEES</b></td>
    </tr>
    <tr bgcolor="#ffff99" class="thinborder"> 
      <td class="thinborder" height="25" align="center"><strong>EMPLOYEE 
        ID</strong></td>
      <td class="thinborder" width="52%" align="center"><strong>EMPLOYEE NAME</strong></td>
			<td width="26%" align="center" class="thinborder"><font size="1"><strong>SET GROUP</strong></font></td>
      <td width="10%" align="center" class="thinborder"><font size="1"><strong>SELECT ALL<br>
      </strong>
          <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();" checked>
      </font></td>
    </tr>
    <% 	//System.out.println("size " +vRetResult.size());
		String strPrevUser = "";		
		int iIncr = 1;
		for(int i = 0; i < vRetResult.size(); i += 7,++iCount){		
		%>
    <tr bgcolor="#FFFFFF" class="thinborder"> 						
 			<input type="hidden" name="emp_set_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
      <%
				if(strPrevUser.equals((String)vRetResult.elementAt(i+6))){
					strTemp = "";			
					strTemp2 = "";		
				}else{
					strTemp = WI.formatName((String)vRetResult.elementAt(i + 2), (String)vRetResult.elementAt(i + 3), (String)vRetResult.elementAt(i + 4),4);					
					strTemp2 = iIncr + ".&nbsp; " + (String)vRetResult.elementAt(i + 1);
					iIncr++;
				}				
			%>
      <td class="thinborder" width="12%" height="25">&nbsp;<%=strTemp2%></td>
      <td class="thinborder" >&nbsp;<%=strTemp%></td>
			<td class="thinborder" >&nbsp;<%=(String)vRetResult.elementAt(i + 5)%></td>
      <td align="center" class="thinborder" >
			<input type="checkbox" name="delete_<%=iCount%>" value="1" checked tabindex="-1">			</td>
			<%
				strPrevUser = (String)vRetResult.elementAt(i+6);
				
			%>
    </tr>
<%} // end for loop%>
	<input type="hidden" name="emp_count" value="<%=iCount%>">

    <tr bgcolor="#FFFFFF" class="thinborder">
      <td height="25" colspan="4" align="center">
			<%if(iAccessLevel == 2){%>
			<font size="1">
        <input type="button" name="delete" value=" Delete " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:DeleteRecord();">
        Click to delete selected 
      </font>
			<%}%>
			</td>
    </tr>	
  </table>	
	<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="print_page">
	<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>