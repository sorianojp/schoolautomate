<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoLicenseETSkillTraining"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);		
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Circular Memo</title>
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
<script src="../../../jscript/common.js"></script>
<script language="JavaScript">
function SearchEmployee(){	
	document.form_.searchEmployee.value="1";
	document.form_.submit();
}

function PrintPg() {
	document.form_.searchEmployee.value="";
	document.form_.print_page.value = "1";
	document.form_.submit()
}

function checkAllSave() {
	var maxDisp = document.form_.emp_count.value;
	var bolIsSelAll = document.form_.selAllSave.checked;
	for(var i =1; i< maxDisp; ++i)
		eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
}

function DeleteRecord(){
	var vProceed = confirm('Remove selected records?');
	if(vProceed){
		document.form_.page_action.value = "0";
		document.form_.searchEmployee.value="1";
		document.form_.print_page.value="";
		document.form_.submit();
	}	
}
function ReloadPage(){
	document.form_.searchEmployee.value="";
	document.form_.print_page.value="";
	document.form_.submit();
}

function UpdateMemoIndex(){
	if (document.form_.memo_sent_index) 
		document.form_.memo_sent_index.selectedIndex = 0;
	document.form_.print_page.value="";
	document.form_.searchEmployee.value="";
	document.form_.submit();
}

function GetMemoDetails(){
	document.form_.memo_name.value = document.form_.memo_index[document.form_.memo_index.selectedIndex].text;
	document.form_.memo_date.value = document.form_.memo_sent_index[document.form_.memo_sent_index.selectedIndex].text;
}

</script>
<%
	String strErrMsg = null;
	String strTemp = null;
	int iSearchResult = 0;
	int i = 0;
	
	//add security here.
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./circular_memo_print.jsp" />
	<% 
		return;}

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-MEMO MANAGEMENT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
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
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR Management-Memo Management-Circular Memo","circular_memo.jsp");
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
	Vector vDates = new Vector();
	
	String strPrepareToEdit =  WI.fillTextValue("prepareToEdit");
	hr.HRMemoManagement  mt = new hr.HRMemoManagement();
	strTemp = WI.fillTextValue("page_action");
	
	if (WI.fillTextValue("memo_index").length() > 0)
		vDates = mt.getMemoDates(dbOP, request, WI.fillTextValue("memo_index"));
	
	if(strTemp.length() > 0){
		if(mt.operateOnMemoCirculation(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = mt.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "Personnel Memo removed successfully.";
		}
	}

	if (WI.fillTextValue("memo_index").length() > 0 && 	WI.fillTextValue("memo_sent_index").length() > 0)
		vRetResult = mt.operateOnMemoCirculation(dbOP, request, 5);
	if(vRetResult == null)
		strErrMsg = mt.getErrMsg();
	
%>
<body bgcolor="#D2AE72" class="bgDynamic" onLoad="GetMemoDetails();">
<form action="./circular_memo.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" bgcolor="#A49A6A" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: MEMO MANAGEMENT PAGE ::::</strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<tr>
  		<td height="25">&nbsp;</td>
		<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
	</tr>
    <tr>
      <td width="3%">&nbsp;</td>
      <td width="17%" height="30">Type of Memo: </td>
 	  <td width="80%" height="30">
        <select name="memo_type_index" onChange="ReloadPage()">
          <option value="">Select Memo Type</option>
          <%=dbOP.loadCombo("memo_type_index","memo_type"," FROM hr_preload_memo_type order by memo_type",WI.fillTextValue("memo_type_index"),false)%>
        </select><font size="1">(optional, filter only)</font></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

    <tr>
      <td width="3%">&nbsp;</td>
      <td width="17%" height="30">Memo Name: </td>
      <td width="80%" ><strong>
        <select name="memo_index" onChange="UpdateMemoIndex()" >
          <option value="">Select Memo</option>
          	<%=dbOP.loadCombo("memo_index","memo_name"," FROM hr_memo_details where is_valid = 1 and is_del = 0 " + 
				WI.getStrValue(WI.fillTextValue("memo_type_index"), "and  memo_type_index = ","","") + 
				" order by memo_name",WI.fillTextValue("memo_index"),false)%>
        </select>
      </strong></td>
    </tr>
<% if (WI.fillTextValue("memo_index").length() > 0) {%> 
    <tr>
      <td>&nbsp;</td>
      <td height="23">Date of Memo : </td>
      <td height="23">
	  	<select name="memo_sent_index" onChange="ReloadPage()">
        <option value="">Select Date of Memo</option>
        <% if(vDates != null && vDates.size() > 0){
			for (i = 0; i < vDates.size();i+=2){
				if (WI.fillTextValue("memo_sent_index").equals((String)vDates.elementAt(i))){
		%>
        		<option value="<%=(String)vDates.elementAt(i)%>" selected> <%=(String)vDates.elementAt(i+1)%></option>
        	<%}else{%>
        		<option value="<%=(String)vDates.elementAt(i)%>"><%=(String)vDates.elementAt(i+1)%></option>
        	<%} // end if else
		} // end for loop
		} //end of vDates%>
      </select></td>
    </tr>
<%}%> 
  </table>

<% if (WI.fillTextValue("memo_sent_index").length() > 0 || WI.fillTextValue("searchEmployee").length() > 0) {
	if (vRetResult !=null && vRetResult.size() == 0) {%> 
		<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr>
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td width="3%">&nbsp;</td>
				<td width="97%"><strong>NO RECEPIENT FOR THIS MEMO.</strong></td>
			</tr>
			<tr>
				<td>&nbsp;</td>
			</tr>
		</table>
	<%}%>  
	
	 <% if (vRetResult != null &&  vRetResult.size() > 0) {%>
		<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
		<tr>   
			<td height="10" colspan="5"><div align="right">
			<a href="javascript:PrintPg()"> <img src="../../../images/print.gif" border="0"></a> 
			<font size="1">click to print</font></div></td>
		</tr>
		<tr>
			<%
				iSearchResult = mt.getSearchCount();
				int iPageCount = iSearchResult/mt.defSearchSize;		
				if(iSearchResult % mt.defSearchSize > 0) 
					++iPageCount;
			%>
			<td colspan="3"><strong>TOTAL RESULT: <%=iSearchResult%> - Showing(<%=mt.getDisplayRange()%>)</strong></td>
			<%
				if(iPageCount > 1){
			%>
		    <td colspan="2"><div align="right"><font size="2">Jump To page:
				<select name="jumpto" onChange="SearchEmployee();">
				<%
					strTemp = WI.fillTextValue("jumpto");
					if(strTemp == null || strTemp.trim().length() ==0) 
						strTemp = "0";
					i = Integer.parseInt(strTemp);
					if(i > iPageCount)
						strTemp = Integer.toString(--i);
		
					for(i =1; i <= iPageCount; ++i ){
						if(i == Integer.parseInt(strTemp) ){%>
							<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
						<%}else{%>
							<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
						<%}
				}%>
				</select>
			</font></div></td>
	      </tr>
		<%}
		else{%>
			<tr><td colspan="2">&nbsp;</td></tr>
		<%}%>
		<tr> 
		  	<td height="20" colspan="8" bgcolor="#B9B292" class="thinborder" align="center"><strong>LIST OF EMPLOYEES</strong></td>
		</tr>
    	<tr>
			<td width="5%" class="thinborder">&nbsp;</td>
			<td width="10%" class="thinborder" align="center"><strong><font size="1">EMPLOYEE ID</font></strong></td> 
			<td width="38%" height="23" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME </font></strong></td>
			<td width="42%" align="center" class="thinborder"><strong><font size="1">DEPARTMENT/OFFICE</font></strong></td>
			<td width="5%" align="center" class="thinborder">
				<font size="1"><strong>SELECT ALL<br></strong>
       		  <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();" checked></font>		  </td>
    	</tr>
		<% 
			int iCount = 1;
	   		for (i = 0; i < vRetResult.size(); i+=8,iCount++){
		%>
    	<tr>
      		<td class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<%=iCount%></span></td>
      		<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td> 
      		<td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;
	  			<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
					(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font></td>
				<%
					if((String)vRetResult.elementAt(i + 5)== null || (String)vRetResult.elementAt(i + 6)== null)
						strTemp = " ";			
					else
						strTemp = " - ";
				%>
      		<td class="thinborder">&nbsp;
	   			<%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"")%>
				<%=strTemp%>
				<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"")%>	  		</td>
     		<td align="center" class="thinborder"> 
				<%if(!((String)vRetResult.elementAt(i+7)).equals("1")){%>       
					<input type="checkbox" name="save_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>" checked tabindex="-1">
				<%}else{%>
					&nbsp;
				<%}%></td>
    	</tr>
    	<%} //end for loop%>
		<input type="hidden" name="emp_count" value="<%=iCount%>">
</table>

	<table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="25" colspan="2" align="center"> 
			<% if (iAccessLevel == 2){%>        
				<a href="javascript:DeleteRecord();"><img src="../../../images/delete.gif" border="0"></a> 
				<font size="1">click to delete checked entries</font> 
			<%} // end iAccessLevel  > 1%></td>
		</tr>
	</table>
 	<%}//end of vRetResult
  }//end of memo_sent_index.length%> 
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF" >&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index">
<input type="hidden" name="page_action">
<input type="hidden" name="print_page">
<input type="hidden" name="searchEmployee" >
<input type="hidden" name="memo_name">
<input type="hidden" name="memo_date">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>