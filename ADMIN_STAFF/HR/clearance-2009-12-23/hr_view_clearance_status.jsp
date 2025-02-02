<%@ page language="java" import="utility.*,java.util.Vector,hr.HRClearance" %>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(6);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>HR View Clearance Status</title>
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
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function viewList(table,indexname,colname,labelname,tablelist,strIndexes, 
					strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + 
	"&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond) + 
	"&extra_cond="+escape(strExtraCond) +
	"&max_len=256&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"viewList",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ReloadPage(){
	document.form_.searchEmployee.value="";
	document.form_.print_page.value="";
	document.form_.submit();
}

function SearchEmployee(){	
	if(document.form_.emp_id.value == '') {
		alert("Please enter employee ID.");
		return;
	} 
	document.form_.searchEmployee.value="1";
	document.form_.print_page.value="";
	document.form_.submit();
}

function PrintPg() {
	document.form_.print_page.value = "1";
	document.form_.submit()
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"OpenSearch",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
var objCOA;
var objCOAInput;
function AjaxMapName(strFieldName, strLabelID) {
	objCOA=document.getElementById(strLabelID);
	var strCompleteName = eval("document.form_."+strFieldName+".value");
	eval('objCOAInput=document.form_.'+strFieldName);
	if(strCompleteName.length <= 2) {
		objCOA.innerHTML = "";
		return ;
	}		
	this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}

	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1"+
	"&name_format=4&complete_name="+escape(strCompleteName);
	this.processRequest(strURL);
}

function UpdateID(strID, strUserIndex) {
	objCOAInput.value = strID;
	objCOA.innerHTML = "";
	//document.dtr_op.submit();
}

function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}

function UpdateNameFormat(strName) {
	//do nothing.
}

</script>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./hr_view_clearance_status_print.jsp" />
	<% 
		return;}
		
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-CLEARANCE"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		if(bolIsSchool)
			request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		else
			request.getSession(false).setAttribute("go_home","../../../index.jsp");
		
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}	
	
	String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
	if(strAuthTypeIndex == null){
		request.getSession(false).setAttribute("go_home","../../../index.jsp");
		request.getSession(false).setAttribute("errorMessage","You are not logged in. Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR Management-Clearance-View Clearance Status","hr_view_clearance_status.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}

	Vector vRetResult = null;
	Vector vClearances = null;
	Vector vItems = null;
	Vector vUserInfo = null;
	HRClearance hrc = new HRClearance();
	int iSearchResult = 0;
	int i = 0;
	
	enrollment.Authentication auth = new enrollment.Authentication();
    request.setAttribute("emp_id", WI.fillTextValue("emp_id"));
    if(WI.fillTextValue("emp_id").length() > 0)
		vUserInfo = auth.operateOnBasicInfo(dbOP, request, "0");
	if(vUserInfo == null)
		strErrMsg = auth.getErrMsg();
	else{
		if(WI.fillTextValue("searchEmployee").length() > 0){
			vRetResult = hrc.ViewClearanceStatus(dbOP, request, (String)vUserInfo.elementAt(0));
			if(vRetResult == null)
				strErrMsg = hrc.getErrMsg();
			else{
				iSearchResult = hrc.getSearchCount();
				vClearances = (Vector)vRetResult.remove(0);
				vItems = (Vector)vRetResult.remove(0);
			}
		}
	}
%>
<body bgcolor="#D2AE72" class="bgDynamic" onLoad="document.form_.emp_id.focus();">
<form action="hr_view_clearance_status.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" align="center" class="footerDynamic">
				<font color="#FFFFFF" ><strong>:::: VIEW CLEARANCE STATUS PAGE ::::</strong></font>			</td>
		</tr>
	</table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="4"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr> 
			<td width="3%" height="25">&nbsp;</td>
			<td width="12%">Employee ID</td>
			<td width="12%" height="25"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('emp_id','emp_id_');"></td>
			<td width="10%" height="25"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
			<td height="25" colspan="3"><label id="emp_id_"></label></td>
		</tr>
		<tr> 
			<td height="10" colspan="7"><hr size="1" color="#000000"></td>
		</tr>
		<tr>
			<td height="10" colspan="7"><strong>OPTIONS:</strong></td>
		</tr>
		<tr> 
		  <td height="10" colspan="2">CLEARANCES:&nbsp;</td>
          <td height="10" colspan="2">
		   <%
			strTemp = WI.getStrValue(WI.fillTextValue("view_all_clearance"),"1");
			if(strTemp.equals("1")) {
				strTemp = " checked";
				strErrMsg = "";
			}
			else {
				strTemp = "";	
				strErrMsg = " checked";
			}
		   %>
	<input type="radio" name="view_all_clearance" value="1"<%=strTemp%> onClick="ReloadPage();">View All Clearances</td>
          <td height="10" colspan="3">
	<input type="radio" name="view_all_clearance" value="0"<%=strErrMsg%> onClick="ReloadPage();">View Uncleared Clearances Only</td>
      </tr>
	  <tr> 
		  <td height="10" colspan="2">ISSUED ITEMS:</td>
          <td height="10" colspan="2">
		  <%
			strTemp = WI.getStrValue(WI.fillTextValue("view_all_items"),"1");
			if(strTemp.equals("1")) {
				strTemp = " checked";
				strErrMsg = "";
			}
			else {
				strTemp = "";	
				strErrMsg = " checked";
			}
			%>
		<input type="radio" name="view_all_items" value="1"<%=strTemp%> onClick="ReloadPage();">View All Issued Items</td>
        <td height="10" colspan="3">
		<input type="radio" name="view_all_items" value="0"<%=strErrMsg%> onClick="ReloadPage();">View Unreturned Items Only </td>
      </tr>
	  <tr>
			<td height="10" colspan="7">&nbsp;</td>
	  </tr>
		<tr>
		  <td height="25" colspan="2">&nbsp;</td>
		  <td height="25" colspan="3"><input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
				onClick="javascript:SearchEmployee();">
            <font size="1">click to display employee list to print.</font></td>
	      <td width="4%" height="25">&nbsp;</td>
		</tr>
	</table>
<%if(vUserInfo!=null && vUserInfo.size() > 0 && WI.fillTextValue("searchEmployee").length() > 0){%>
  	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>   
			<td height="10" colspan="5"><div align="right">
			<a href="javascript:PrintPg()"> <img src="../../../images/print.gif" border="0"></a> 
			<font size="1">click to print</font></div></td>
		</tr>
		<tr> 
			<td height="10" colspan="5"><hr size="1" color="#000000"></td>
		</tr>
		<tr>
        	<td height="25" colspan="2">Employee Information: </td>
	    	<td colspan="3">&nbsp;</td>
      	</tr>
		<tr> 
			<td width="5%" height="25">&nbsp;</td>
			<td width="18%">Employee ID:</td>
			<td width="77%" colspan="3"><%=WI.fillTextValue("emp_id")%></td>
	    </tr>
		<tr>
			<td width="5%" height="25">&nbsp;</td>
			<td width="18%">Name:</td>
		    <td colspan="3"><%=WebInterface.formatName((String)vUserInfo.elementAt(1), (String)vUserInfo.elementAt(2), (String)vUserInfo.elementAt(3), 4)%></td>
	    </tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>Department/Office:</td>
		  <%
		  	if((String)vUserInfo.elementAt(13)== null || (String)vUserInfo.elementAt(14)== null)
				strTemp = " ";			
			else
				strTemp = " - ";
		  %>
		  <td colspan="3">
		  <%=WI.getStrValue((String)vUserInfo.elementAt(13),"")%>
		  <%=strTemp%>
		  <%=WI.getStrValue((String)vUserInfo.elementAt(14),"")%> 
		  </td>
	  </tr>
	  <tr>
	  	<td colspan="3">&nbsp;</td>
	  </tr>
  	</table>
<%} if (vClearances != null &&  vClearances.size() > 0) {%>
  	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="10">&nbsp;</td>
		</tr>
  	</table>
	
  	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<%
			if(WI.fillTextValue("view_all_clearance").equals("1"))
				strTemp = "ALL";
			else
				strTemp = "UNCLEARED";
		%>
		<tr> 
		  	<td height="20" colspan="7" bgcolor="#B9B292" class="thinborder"><div align="center"><strong>LIST OF <%=strTemp%> CLEARANCES </strong></div></td>
		</tr>
    	<tr>
			<td width="7%" height="23" class="thinborder">&nbsp;</td>
			<td width="20%" align="center" class="thinborder"><strong><font size="1">CLEARANCE NAME</font></strong></td>
			<td width="19%" align="center" class="thinborder"><strong><font size="1">REMARK</font></strong></td>
			<td width="23%" align="center" class="thinborder"><strong><font size="1">POSTED BY</font></strong></td>
			<td width="18%" align="center" class="thinborder"><strong><font size="1">DATE POSTED</font></strong></td>
			<%if(WI.fillTextValue("view_all_clearance").equals("1")){%>
			<td width="13%" align="center" class="thinborder"><strong><font size="1">STATUS</font></strong></td>
			<%}%>
		</tr>
    	<% 
			int iCount = 1;
	   		for (i = 0; i < vClearances.size(); i+=7,iCount++){
				String strTableColor = "#FFFFFF";
				String strTextColor = "#000000";
				strTemp = (String)vClearances.elementAt(i+5);//1 - clearance is cleared, else uncleared
				if(strTemp.equals("0")){
					strTableColor = "#FF0000";
					strTextColor = "#FFFF00";
				}

		%>
    	<tr bgcolor="<%=strTableColor%>">
      		<td height="25" class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<font color="<%=strTextColor%>"><%=iCount%></font></span></td>
			<td class="thinborder"><font color="<%=strTextColor%>"><%=(String)vClearances.elementAt(i)%></font></td>
			<td class="thinborder"><font color="<%=strTextColor%>"><%=(String)vClearances.elementAt(i+1)%></font></td>
			<td class="thinborder"><font color="<%=strTextColor%>">
			<%=WebInterface.formatName((String)vClearances.elementAt(i+2),(String)vClearances.elementAt(i+3), (String)vClearances.elementAt(i+4), 7)%></font></td>
      		<td class="thinborder"><font color="<%=strTextColor%>"><%=(String)vClearances.elementAt(i+6)%></font></td>
			<%if(WI.fillTextValue("view_all_clearance").equals("1")){
				strTemp = (String)vClearances.elementAt(i+5);
				if(strTemp.equals("1"))
					strTemp = "CLEARED";
				else
					strTemp = "UNCLEARED";
			%>
      		<td class="thinborder"><font color="<%=strTextColor%>"><%=strTemp%></font></td>
			<%}%>
   		</tr>
    	<%} //end for loop%>
	</table>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="FFFFFF">
		<tr>
			<td height="25"></td>
		</tr>
	</table>
	<%}if(vClearances==null && vRetResult!=null){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="10">&nbsp;</td>
		</tr>
  	</table>
	
  	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
		<%
			if(WI.fillTextValue("view_all_clearance").equals("1"))
				strErrMsg = "NO POSTED CLEARANCES.";
			else
				strErrMsg = "NO UNCLEARED CLEARANCES.";
		%>
		<tr>
			<td height="25" colspan="6"><strong>CLEARANCE STATUS: <%=strErrMsg%></strong></td>
		</tr>
		<tr>
      		<td height="25" colspan="6">&nbsp;</td>
    	</tr>
	</table>	
	<%}
	
	if (vItems != null &&  vItems.size() > 0) {%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
	<%
		if(WI.fillTextValue("view_all_items").equals("1"))
			strTemp = "ALL";
		else
			strTemp = "TO BE RETURNED";
	%>
	<tr> 
	  	<td height="20" colspan="9" bgcolor="#B9B292" class="thinborder"><div align="center"><strong>LIST OF <%=strTemp%> ISSUED ITEMS</strong></div></td>
	</tr>
    <tr>
		<td width="6%"  height="23" class="thinborder">&nbsp;</td>
		<td width="21%" align="center" class="thinborder"><strong><font size="1">PROPERTY #. </font></strong></td>
		<td width="19%" align="center" class="thinborder"><strong><font size="1">DATE ISSUED </font></strong></td>
		<td width="23%" align="center" class="thinborder"><strong><font size="1">ISSUED BY </font></strong></td>
		<%if(WI.fillTextValue("view_all_items").equals("1")){%>
		<td width="18%" align="center" class="thinborder"><strong><font size="1">TO BE RETURNED?</font></strong></td>
		<td width="13%" align="center" class="thinborder"><strong><font size="1">STATUS</font></strong></td>
		<%}%>
	</tr>
	<% 
		int iCount = 1;
	  		for (i = 0; i < vItems.size(); i+=7,iCount++){
				String strTableColor = "#FFFFFF";
				String strTextColor = "#000000";
				strTemp = (String)vItems.elementAt(i+5);//to be returned?
				strErrMsg = (String)vItems.elementAt(i+1);//returned date
				if(strTemp.equals("1") && strErrMsg == null){
					strTableColor = "#FF0000";
					strTextColor = "#FFFF00";
				}
	%>
    <tr bgcolor="<%=strTableColor%>">
    	<td height="25" class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<font color="<%=strTextColor%>"><%=iCount%></font></span></td>
    	<td class="thinborder"><font color="<%=strTextColor%>"><%=(String)vItems.elementAt(i)%></font></td>
     	<td class="thinborder"><font color="<%=strTextColor%>"><%=vItems.elementAt(i+6)%></font></td>
      	<td class="thinborder"><font color="<%=strTextColor%>">
			<%=WebInterface.formatName((String)vItems.elementAt(i+2),(String)vItems.elementAt(i+3),(String)vItems.elementAt(i+4),7)%></font></td>
		<%	if(WI.fillTextValue("view_all_items").equals("1")){
				strTemp = (String)vItems.elementAt(i+5);
				if(strTemp.equals("1"))
					strTemp = "YES";
				else
					strTemp = "NO";
				
				strErrMsg = (String)vItems.elementAt(i+1);

				if(strErrMsg != null)
					strErrMsg = "RETURNED";
				else{//else if the returned date is not null
					if(strTemp.equals("YES"))
						strErrMsg = "UNRETURNED";
					else
						strErrMsg = "NOT TO BE RETURNED";
				}
		%>
		<td class="thinborder"><font color="<%=strTextColor%>"><%=strTemp%></font></td>
		<td class="thinborder"><font color="<%=strTextColor%>"><%=strErrMsg%></font></td> <%}%>
      </tr>
    	<%} //end for loop%>
	</table>
<%}if(vItems==null  && vRetResult!=null){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
	<%
		if(WI.fillTextValue("view_all_items").equals("1"))
			strErrMsg = "NO ITEMS ISSUED.";
		else
			strErrMsg = "NO TO BE RETURNED ITEMS ISSUED.";
	%>
	<tr>
		<td height="25" colspan="6"><strong>ISSUED ITEMS STATUS: <%=strErrMsg%></strong></td>
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
	<input type="hidden" name="searchEmployee" > 
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>