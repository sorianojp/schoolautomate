<%@ page language="java" import="utility.*,java.util.Vector,hr.HRMemoManagement"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Circulate Memo</title>
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
<script src="../../../Ajax/ajax.js"></script>
<script src="../../../jscript/date-picker.js"></script>
<script src="../../../jscript/td.js"></script>
<script src="../../../jscript/common.js"></script>
<script language="JavaScript">
function checkAllSave() {
	var maxDisp = document.form_.emp_count.value;
	var bolIsSelAll = document.form_.selAllSave.checked;
	for(var i =1; i< maxDisp; ++i)
		eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
}

function SearchEmployee(){	
	document.form_.searchEmployee.value="1";
	document.form_.submit();
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"OpenSearch",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ResetPosition(){
	if(document.form_.emp_type_index.selectedIndex>0){
		document.form_.emp_type_index.selectedIndex = 0;
	}
}

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
	document.getElementById("coa_info").innerHTML = "";
//	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function ReloadPage(){
	document.form_.searchEmployee.value="";
	document.form_.submit();
}

function AddRecord(){
	document.form_.searchEmployee.value="1";
	document.form_.page_action.value="1";
	document.form_.submit();
}

</script>

<%
	String strErrMsg = null;
	String strTemp = null;

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
			"Admin/staff-HR Management-Memo Management-Circulate Memo","circulate_memo.jsp");
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
	Vector vVariables = null;
	Vector vVarValues = null;

	String[] astrSortByName    = {"Employee ID","Firstname","Lastname","Division","Department"};
	String[] astrSortByVal     = {"id_number","user_table.fname","lname","c_name","d_name"};
	
	int i = 0;
	int iSearchResult = 0;
	
	HRMemoManagement  mt = new HRMemoManagement();
	
	strTemp = WI.fillTextValue("page_action");
	
	if(strTemp.length() > 0){
		if(mt.operateOnMemoCirculation(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = mt.getErrMsg();
		else {
			if(strTemp.equals("0"))
				strErrMsg = "Memo removed successfully.";
			if(strTemp.equals("1")){
				strErrMsg = "Memo sent successfully.";
			}
		}
	}
	
	if (WI.fillTextValue("memo_index").length() > 0){
		vVariables = mt.parseMemoContent(dbOP, WI.fillTextValue("memo_index"));	
		if(vVariables!=null && vVariables.size() > 0)
			vVarValues = mt.operateOnVariableValues(dbOP,request, WI.fillTextValue("memo_index"));
		else if(vVariables == null)
			strErrMsg = mt.getErrMsg();
	}					 
	
	if(WI.fillTextValue("searchEmployee").length() > 0){
	    vRetResult = mt.operateOnMemoCirculation(dbOP, request, 4);
		if(vRetResult == null && strTemp.length()==0)
			strErrMsg = mt.getErrMsg();
		else
			iSearchResult = mt.getSearchCount();
	}

%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="./circulate_memo.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic" align="center">
	  	<font color="#FFFFFF" ><strong>:::: CIRCULATE MEMO FOR PERSONNEL ::::</strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<tr>
		<td height="25">&nbsp;</td>
		<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
	</tr>
    <tr>
      <td width="3%">&nbsp;</td>
      <td width="19%" height="30">TYPE OF MEMO </td>
 	  <td width="78%" height="30">
        <select name="memo_type_index" onChange="ReloadPage()">
          <option value="">Select Memo Type</option>
          <%=dbOP.loadCombo("memo_type_index","memo_type"," FROM hr_preload_memo_type order by memo_type",WI.fillTextValue("memo_type_index"),false)%>
      	</select><font size="1">(optional, filter only)</font></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

    <tr>
      <td width="3%">&nbsp;</td>
      <td width="19%" height="30" valign="bottom">MEMO  NAME </td>
      <td colspan="2" valign="bottom"><strong>
        <select name="memo_index" onChange="ReloadPage();">
          <option value="">Select Memo</option>
          <%=dbOP.loadCombo("memo_index","memo_name",
	  				" FROM hr_memo_details where is_valid = 1 and is_del = 0 " + WI.getStrValue(WI.fillTextValue("memo_type_index"),
					"and  memo_type_index = ","","") + " order by memo_name",WI.fillTextValue("memo_index"),false)%>
        </select></strong></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="23" colspan="3">&nbsp;</td>
    </tr>
		<tr>
			<td height="24">&nbsp;</td>
			<td>Status</td>
			<td colspan="3">
				<select name="pt_ft" onChange="ReloadPage();">
				<option value="">All</option>
				<%if (WI.fillTextValue("pt_ft").equals("0")){%>
					<option value="0" selected>Part-time</option>
				<%}else{%>
					<option value="0">Part-time</option>
					
				<%}if (WI.fillTextValue("pt_ft").equals("1")){%>
					<option value="1" selected>Full-time</option>
				<%}else{%>
					<option value="1">Full-time</option>
				<%}%>
				</select></td>
		</tr>
		<% 	
			String strCollegeIndex = WI.fillTextValue("c_index");	
		%>
		<tr> 
			<td height="24">&nbsp;</td>
			<td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
			<td colspan="3">
				<select name="c_index" onChange="ReloadPage();">
					<option value="">N/A</option>
					<%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%>
				</select>
			</td>
		</tr>
		<tr> 
			<td height="25">&nbsp;</td>
			<td>Department/Office</td>
			<td colspan="3">
				<select name="d_index" onChange="ReloadPage();">
					<option value="">ALL</option>
					<%if (strCollegeIndex.length() == 0){%>
						<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
					<%}else if (strCollegeIndex.length() > 0){%>
						<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
					<%}%>
				</select>
			</td>
		</tr>
		<tr>
			<td height="15" colspan="5"></td>
		</tr>
<% if (vVariables != null && vVariables.size() > 0) {%> 
    <tr bgcolor="#DDE7FF">
      <td>&nbsp;</td>
      <td height="23"><strong>Variables : </strong></td>
      <td height="23" colspan="2">&nbsp; </td>
    </tr>
<% for (int k = 0; k < vVariables.size(); k++) {%> 
	<tr>
	  <td>&nbsp;</td>
	  <td height="23">&nbsp;
	  <input type="hidden" name="var_<%=k%>" value="<%=(String)vVariables.elementAt(k)%>">
			<%=(String)vVariables.elementAt(k)%></td>
	<%
		String strReadOnly = "";
		String strValue = WI.fillTextValue("value_"+k);
		if(vVarValues!=null && vVarValues.size() > 0){
			strReadOnly = "readonly";
			strValue = (String)vVarValues.elementAt(k);
		}
	%>
		
	  <td height="23" colspan="2">
	  	<%if(strReadOnly.length() > 0){%>
		&nbsp;<input type="hidden" name="value_<%=k%>" value="<%=strValue%>"><%=(String)vVarValues.elementAt(k)%>
		<%}else{%>
		<input name="value_<%=k%>" type="text" class="textbox" 
		 	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
		 	value="<%=strValue%>" size="64" maxlength="256" <%=strReadOnly%>>
		<%}%>
	  </td>
	</tr>
<%}%> 
    <tr >
      <td>&nbsp;<input type="hidden" value="<%=vVariables.size()%>" name="var_length"></td>
      <td height="23">&nbsp;</td>
      <td height="23" colspan="2">&nbsp;</td>
    </tr>
<%}%> 

    <tr >
      <td>&nbsp;</td>
      <td height="23"><strong><font color="#FF0000">Date of Sending </font></strong></td>
<%
	strTemp = WI.fillTextValue("date_send");
	if (strTemp.length() == 0) 
		strTemp = WI.getTodaysDate(1);
%>
      <td width="39%" height="23">
	  <input name="date_send" type="text" class="textbox" 
		  onFocus="style.backgroundColor='#D3EBFF'"
		  readonly="yes"
		  onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','date_send','/')"
		  onKeyUP="AllowOnlyIntegerExtn('form_','date_send','/')"
		  value="<%=strTemp%>" size="10" maxlength="10"> 
		<a href="javascript:show_calendar('form_.date_send')"><img src="../../../images/calendar_new.gif" border="0" on></a></td>
		
      <td width="39%">&nbsp;</td>
    </tr>

    <tr >
      <td height="20">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" bgcolor="#FAEDE2">&nbsp;</td>
      <td width="19%" height="23" bgcolor="#FAEDE2">&nbsp;</td>
      <td height="23" colspan="3" bgcolor="#FAEDE2"><strong>SELECT RECIPIENT(S) FOR THIS MEMO</strong></td>
    </tr>
    <tr>
      <td width="3%">&nbsp;</td>
      <td height="43">SPECIFIC EMPLOYEE </td>
      <td width="19%" height="43">
	  	<input name="emp_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onKeyUp="AjaxMapName();ResetPosition();" value="<%=WI.fillTextValue("emp_id")%>"
		onBlur="style.backgroundColor='white'" size="16" ></td>
      <td width="5%" align="center"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" name="add_1" border="0"></a></td>
      <td width="54%">&nbsp;<label id="coa_info"></label></td>
    </tr>
	<tr>
      <td>&nbsp;</td>
      <td height="30">POSITION </td>
      <td height="30" colspan="3"><strong>
        <select name="emp_type_index">
          <option value="">Select Group / Position </option>
          <%=dbOP.loadCombo("emp_type_index","emp_type_name",
		  		" FROM hr_employment_type where is_del = 0 " +
				" order by position_order, emp_type_name",WI.fillTextValue("emp_type_index"),false)%>
        </select>
      </strong></td>
	</tr>
	<tr>
		<td colspan="5" height="15"></td>
	</tr>
</table>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td height="25">&nbsp;</td>
        <td colspan="5">
			<%
				if(WI.fillTextValue("view_all").length() > 0)
					strTemp = " checked";				
				else
					strTemp = "";
			%>
			<input name="view_all" type="checkbox" value="1"<%=strTemp%> onClick="ReloadPage();"> View ALL
		</td>
      </tr>
      <tr>
        <td width="3%" height="29">&nbsp;</td>
        <td>SORT BY :</td>
        <td><select name="sort_by1">
            <option value="">N/A</option>
            <%=mt.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
        </select></td>
        <td><select name="sort_by2">
            <option value="">N/A</option>
            <%=mt.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
        </select></td>
        <td colspan="2"><select name="sort_by3">
            <option value="">N/A</option>
            <%=mt.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
        </select></td>
      </tr>
      <tr>
        <td height="15">&nbsp;</td>
        <td width="11%" height="15">&nbsp;</td>
        <td><select name="sort_by1_con">
            <option value="asc">Ascending</option>
            <%
						if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
            <option value="desc" selected>Descending</option>
            <%}else{%>
            <option value="desc">Descending</option>
            <%}%>
          </select>        </td>
        <td><select name="sort_by2_con">
            <option value="asc">Ascending</option>
            <%
						if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
            <option value="desc" selected>Descending</option>
            <%}else{%>
            <option value="desc">Descending</option>
            <%}%>
          </select>        </td>
        <td colspan="2"><select name="sort_by3_con">
            <option value="asc">Ascending</option>
            <%
						if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
            <option value="desc" selected>Descending</option>
            <%}else{%>
            <option value="desc">Descending</option>
            <%}%>
          </select>        </td>
      </tr>
      <tr>
        <td height="10">&nbsp;</td>
        <td height="10">&nbsp;</td>
        <td height="10" colspan="3">&nbsp;</td>
      </tr>
      <tr>
        <td height="10">&nbsp;</td>
        <td height="10">&nbsp;</td>
        <td height="10" colspan="3"><input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
				onClick="javascript:SearchEmployee();">
            <font size="1">click to display employee list to print.</font></td>
      </tr>
      <tr>
        <td colspan="5">&nbsp;</td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <%
			int iPageCount = 1;
			if(vRetResult!=null && vRetResult.size() > 0){
				if(WI.fillTextValue("view_all").length() == 0){
					iPageCount = iSearchResult/mt.defSearchSize;		
					if(iSearchResult % mt.defSearchSize > 0) 
						++iPageCount;
					strTemp = " - Showing("+mt.getDisplayRange()+")";
				}
				else
					strTemp = " - Showing All";
		%>
			<td colspan="3"><strong>TOTAL RESULT: <%=iSearchResult%><%=strTemp%></strong></td>
		<%}
			if(iPageCount > 1){
		%>
		    <td><div align="right"><font size="2">Jump To page:
				<select name="jumpto" onChange="SearchEmployee();">
				<%
					strTemp = WI.fillTextValue("jumpto");
					if(strTemp == null || strTemp.trim().length() ==0)
						strTemp = "0";
					i = Integer.parseInt(strTemp);
					if(i > iPageCount)
						strTemp = Integer.toString(--i);
		
					for(i =1; i<= iPageCount; ++i ){
						if(i == Integer.parseInt(strTemp) ){%>
							<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
						<%}else{%>
							<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
						<%}
				}%>
				</select>
				</font></div></td>
		</tr>
		<%}%>
    </table>
	<% if (vRetResult != null &&  vRetResult.size() > 0) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="8" bgcolor="#B9B292" class="thinborder" align="center"><strong>LIST OF EMPLOYEES</strong></td>
		</tr>
    	<tr>
			<td width="5%" class="thinborder">&nbsp;</td>
			<td width="10%" class="thinborder" align="center"><strong><font size="1">EMPLOYEE ID</font></strong></td> 
			<td width="37%" height="23" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME </font></strong></td>
			<td width="43%" align="center" class="thinborder"><strong><font size="1">DEPARTMENT/OFFICE</font></strong></td>
			<td width="5%" align="center" class="thinborder">
				<font size="1"><strong>SELECT ALL<br>
				</strong>
       		  <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();" checked></font>
		  </td>
    	</tr>
		<% 
			int iCount = 1;
	   		for (i = 0; i < vRetResult.size(); i+=7,iCount++){
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
				<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"")%> 
	  		</td>
     		<td align="center" class="thinborder">        
				<input type="checkbox" name="save_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>" checked tabindex="-1">
			</td>
    	</tr>
    	<%} //end for loop%>
		<input type="hidden" name="emp_count" value="<%=iCount%>">
</table>

<table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
	<tr> 
    	<td height="25" colspan="2" align="center"> 
        <% if (iAccessLevel > 1){%>        
        	<a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0"></a> 
        	<font size="1">click to save all entries</font> 
        <%} // end iAccessLevel  > 1%></td>
    </tr>
</table>
<%}%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF" >&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="page_action">
<input type="hidden" name="searchEmployee" >

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>