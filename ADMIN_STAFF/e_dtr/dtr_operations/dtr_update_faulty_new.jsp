<%@ page language="java" import="utility.*,java.util.Vector,eDTR.TimeInTimeOut, eDTR.ReportEDTRExtn"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(7);
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Update Selected faulty employee dtr</title>
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
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function checkAllSave() {
	var maxDisp = document.form_.emp_count.value;
	//unselect if it is unchecked.
	if(!document.form_.selAllSave.checked) {
		for(var i =0; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=false');
	}
	else {
		for(var i =0; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=true');
	}
}

function updateDTR()
{
	document.form_.update_records.value="1";
	this.SubmitOnce('form_');
}
function ViewRecords() {	
	document.form_.viewRecords.value="1";
	document.form_.update_records.value="";
	document.form_.submit();
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
	document.getElementById("coa_info").innerHTML = "";
	//document.form_.submit();
}

function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}

function UpdateNameFormat(strName) {
	//do nothing.
}

function ShowHideLabel(strShowHide){

	if(strShowHide == '1'){		
		document.getElementById('note').style.visibility = "visible";
	}else{
		document.getElementById('note').style.visibility = "hidden";
	}
}
</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolHasTeam = false;
	
//add security here
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Statistics & Reports-Update Faulty DTR","dtr_update_faulty_new.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
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
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
														"dtr_update_faulty_new.jsp");	
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
if(strErrMsg == null) 
	strErrMsg = "";

TimeInTimeOut RE = new TimeInTimeOut();
ReportEDTRExtn rptDTRExtn = new ReportEDTRExtn(request);
int iResult = 0;
Vector vRetResult = null;
	if(bolIsSchool)
		strTemp = "College";
	else
		strTemp = "Division";	
	String[] astrSortByName = {"Employee ID","Firstname","Lastname",strTemp,"Department"};
	String[] astrSortByVal  = {"id_number","user_table.fname","lname","c_name","d_name"};
	String[] astrLoginSet = {"First Login Set","Second Login Set"};
	String[] astrShowOption = {"", "Show only with dtr for the day", "Show only not updated for the day"};
	int iSearchResult  = 0;
	int i = 0;

	if (WI.fillTextValue("update_records").equals("1")){
		vRetResult = rptDTRExtn.operateOnSelectedFaultyDTR(dbOP,request,1);
		if (vRetResult == null)
			strErrMsg = rptDTRExtn.getErrMsg();
		else
			strErrMsg = "Operation Successful";
	}

	vRetResult = rptDTRExtn.operateOnSelectedFaultyDTR(dbOP, request, 4);
	if(vRetResult != null)
		iSearchResult = rptDTRExtn.getSearchCount();
%>
<form name="form_" action="./dtr_update_faulty_new.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        DTR OPERATIONS - UPDATE FAULTY RECORDS ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" ><strong><font color="#FF0000" size="3">&nbsp;<%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    

    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="19%" height="25">Date</td>
      <%
				strTemp = WI.fillTextValue("update_date");
				if(strTemp.length() == 0)
					strTemp = WI.getTodaysDate(1);
			%>
			<td width="77%" height="25">
			<input name="update_date" type="text" size="10" maxlength="10" 
				value="<%=strTemp%>" class="textbox" 
				onKeyUp="AllowOnlyIntegerExtn('form_','update_date','/');"
				onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','update_date','/')">
        <a href="javascript:show_calendar('form_.update_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    
    <% 	
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
    <tr>
      <td height="25">&nbsp;</td>
      <td><%if(bolIsSchool){%>
        College
          <%}else{%>
        Division
        <%}%></td>
      <td><select name="c_index" onChange="ViewRecords();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%>
        </select>      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td><select name="d_index" onChange="ViewRecords();">
          <option value="">ALL</option>
          <%if (strCollegeIndex.length() == 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%>
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%>
          <%}%>
        </select>			</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Office/Dept filter </td>
      <td height="25"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters)</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Employee Type </td>
      <%
				strTemp = WI.fillTextValue("emp_type_index");			
			%>
			<td>			
			<select name="emp_type_index">
				<option value="">ALL</option>
				<%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 " +
 				"order by EMP_TYPE_NAME asc", strTemp, false)%>
			</select>			</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"> Employee ID </td>
      <td height="25"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox" 
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);">
			<label id="coa_info" style="position:absolute; width:350px;"></label>
			</td>
    </tr>
		 <%if(bolHasTeam){%>
		<tr>
      <td height="25">&nbsp;</td>
      <td>Team</td>
      <td>
			<select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select>      </td>
    </tr>
		
		<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>List option </td>
      <td><select name="show_option">
        <% strTemp = WI.fillTextValue("show_option"); %>
        <option value="" >ALL</option>
        <%
					for(i = 1; i < astrShowOption.length; i++){
						if(strTemp.equals(Integer.toString(i))){
				%>
        <option value="<%=i%>" selected><%=astrShowOption[i]%></option>
        <%}else{%>
        <option value="<%=i%>"><%=astrShowOption[i]%></option>
        <%}
				}%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">
			<%if (WI.fillTextValue("view_all").equals("1")) 
			strTemp = "checked";
			else
				strTemp = "";
		%>
        <input type="checkbox" name="view_all" value="1" <%=strTemp%>>
        <font size="1"> show all</font></td>
    </tr>
	</table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td>SORT BY :</td>
      <td><select name="sort_by1">
          <option value="">N/A</option>
          <%=rptDTRExtn.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
          </select>
			</td>
      <td>
					<select name="sort_by2">
          <option value="">N/A</option>
          <%=rptDTRExtn.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
          </select>      </td>
      <td><select name="sort_by3">
        <option value="">N/A</option>
        <%=rptDTRExtn.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
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
      </select></td>
      <td><select name="sort_by2_con">
        <option value="asc">Ascending</option>
        <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
        <option value="desc" selected>Descending</option>
        <%}else{%>
        <option value="desc">Descending</option>
        <%}%>
      </select></td>
      <td><select name="sort_by3_con">
        <option value="asc">Ascending</option>
        <%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
        <option value="desc" selected>Descending</option>
        <%}else{%>
        <option value="desc">Descending</option>
        <%}%>
      </select></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">
			<input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ViewRecords();">
        <font size="1">click to proceed</font></td>
    </tr>
  </table>	
	<%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    
    <%if(WI.fillTextValue("view_all").length() == 0){
			int iPageCount = iSearchResult/rptDTRExtn.defSearchSize;		
			if(iSearchResult % rptDTRExtn.defSearchSize > 0) ++iPageCount;
			if(iPageCount > 1){%>
    <tr>
      <td><div align="right"><font size="2">Jump To page:
        <select name="jumpto" onChange="ViewRecords();">
      <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i )
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
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="20" colspan="5" align="center" bgcolor="#B9B292" class="thinborder"><strong>LIST OF EMPLOYEES</strong></td>
    </tr>
    
    <tr>
      <td width="3%" class="thinborder">&nbsp;</td>
      <td width="6%" class="thinborder">&nbsp;</td>
      <td width="35%" height="23" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME </font></strong></td>
      <td width="32%" align="center" class="thinborder"><strong><font size="1">DEPARTMENT/OFFICE</font></strong></td>
      <td width="6%" align="center" class="thinborder"><font size="1"><strong>SELECT ALL<br>
        </strong>
        <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();">
      </font></td>
    </tr>
    <% 	int iCount = 0;
	   for (i = 0; i < vRetResult.size(); i+=9,iCount++){
		 %>
    <tr>
			<input type="hidden" name="user_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
      <input type="hidden" name="id_number_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+1)%>">			
			<td class="thinborder">&nbsp;<%=iCount+1%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td> 
      <td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font></td>			
      <%if((String)vRetResult.elementAt(i + 5)== null || (String)vRetResult.elementAt(i + 6)== null){
		  	strTemp = " ";			
		  }else{
		  	strTemp = " - ";
		  }			
		%>		
		
      <td class="thinborder">&nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"")%></td>
		  <%
				strTemp = WI.fillTextValue("save_"+iCount);
				if(strTemp.equals("1"))
					strTemp = "checked";
				else
					strTemp = "";
			%>			
      <td align="center" class="thinborder"><input type="checkbox" name="save_<%=iCount%>" value="1" tabindex="-1" <%=strTemp%>>      </td>
    </tr>
    <%} //end for loop%>
    
    <input type="hidden" name="emp_count" value="<%=iCount%>">
  </table>
	
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr>
      <td height="25" colspan="2"  bgcolor="#FFFFFF"><table width="80%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="21%">Copy Time </td>					
          <td width="79%">
					<select name="update_in_out">
					<% strTemp = WI.fillTextValue("update_in_out"); %>
            <option value="1">Logout only</option>
            <% if(strTemp.equals("2")){%>
            <option value="2" selected>Both (Login and logout)</option>
            <%}else{%>
            <option value="2">Both (Login and logout)</option>
            <%}%>
          </select>
					
					<select name="am_pm">
						<% strTemp = WI.fillTextValue("am_pm"); %>
						<option value="" >Whole Day</option>
						<%
							for(i = 0; i < astrLoginSet.length; i++){
								if(strTemp.equals(Integer.toString(i))){
						%>
		            <option value="<%=i%>" selected><%=astrLoginSet[i]%></option>
	            <%}else{%>
		            <option value="<%=i%>"><%=astrLoginSet[i]%></option>
            <%}
						}%>
          </select></td>
          </tr>
        
      </table></td>
    </tr>
    <tr>
      <td width="14%" height="18"  bgcolor="#FFFFFF"><a href='javascript:ShowHideLabel("1")' title="click to see help"><img src="../../../images/online_help.gif" width="34" height="26" border="0">NOTES</a>			  </td>
      <td width="86%"  bgcolor="#FFFFFF"><div id="note" style="position:absolute; visibility:hidden; width:auto; overflow:auto;">
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#CCCCCC">
				<tr>
					<td width="90%">
					1. Use this to copy the working hour schedule of the employees selected to their dtr for the  day. <br>
								2. Employees with flexible working schedule will be ignored.<br>
								3. If you chose to update both the login and logout of the employees, whatever late and undertime recorded for the login set will be removed. </td>
					<td width="10%" align="center"><a href="javascript:ShowHideLabel('0');"><strong><font size="2" color="#FF0000">HIDE</font></strong></a></td>
				</tr>
				</table>
			</div></td>
    </tr>
    
    <tr>
      <td height="18" colspan="2"  bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="2"  bgcolor="#FFFFFF">
			<%if(iAccessLevel == 2){%>
			<input type="button" name="122" value=" Update " style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
			onClick="javascript:updateDTR();" title="Click to update dtr of selected employees">
			<%}else{%>
				Not permitted to use this page
			<%}%>
			</td>
    </tr>
  </table>
	<%}%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#ffffff">
      <td height="25">&nbsp;</td>
    </tr>  
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25">&nbsp;</td>
    </tr>  
	</table>	  
	<input type="hidden" name="viewRecords">
	<input type="hidden" name="update_records">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>