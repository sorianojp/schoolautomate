<%@ page language="java" import="utility.*, visitor.VisitLog, visitor.VisitorInfo, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	if(request.getSession(false).getAttribute("userIndex") == null){
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Record Going In</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css"></head>
<script language="javascript" src="../../Ajax/ajax.js"></script>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">

	function CancelOperation(){
		location = "./record_going_in.jsp?info_index="+document.form_.info_index.value;
	}
	
	function ReloadPage(){
		document.form_.submit();
	}
	
	function UpdateIDs(){
		var pgLoc = "./update_id.jsp";	
		var win=window.open(pgLoc,"UpdateIDs",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function UpdateEvent(){
		var pgLoc = "./event_mgmt.jsp?forwarded=1";	
		var win=window.open(pgLoc,"UpdateIDs",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}

	function SaveRecord(){
		document.form_.save_record.value = "1";
		document.form_.submit();
	}
	
	function OpenSearch() {
		var pgLoc = "../../search/srch_emp.jsp?opner_info=form_.emp_id";
		var win=window.open(pgLoc,"OpenSearch",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
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
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
	}
	
	function UpdateID(strID, strUserIndex) {
		document.form_.emp_id.value = strID;
		//document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
		document.getElementById("coa_info").innerHTML = "";
		document.form_.submit();
	}
	
	function UpdateName(strFName, strMName, strLName) {
		//do nothing.
	}
	function UpdateNameFormat(strName) {
		//do nothing.
	}
	
	function UploadPicture(strInfoIndex){
		var sT = "./upload_picture.jsp?visitor_index="+strInfoIndex+"&opner_form_name=form_";
		var win=window.open(sT,"UploadPicture",'dependent=yes,width=700,height=200,top=200,left=100,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.form_.c_index[document.form_.c_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+"&sel_name=d_index&all=1";
		//alert(strURL);
		this.processRequest(strURL);
}
	
</script>
<%
	DBOperation dbOP = null;		
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Visitor Management-Record Going In","record_going_in.jsp");
	}
	catch(Exception exp) {
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
															"Visitor Management","Record Going In Out",request.getRemoteAddr(),
															"record_going_in.jsp");
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}
	//end of authenticaion code.
	
	Vector vStudInfo = null;
	Vector vVisitorInfo = null;
	String strVisitorIndex = WI.fillTextValue("info_index");	
	VisitLog visitLog = new VisitLog();
	VisitorInfo visitorInfo = new VisitorInfo();
	
	if(strVisitorIndex.length() > 0){
		vVisitorInfo = visitorInfo.operateOnVisitorInfo(dbOP, request, 3);
		if(vVisitorInfo == null)
			strErrMsg = visitorInfo.getErrMsg();
		else{
			strTemp = WI.fillTextValue("emp_id");
			if(strTemp.length() > 0){
				request.setAttribute("emp_id", strTemp);
				vStudInfo = new enrollment.Authentication().operateOnBasicInfo(dbOP, request,"0");
				//System.out.println(vStudInfo);
			}
			
			if(WI.fillTextValue("save_record").length() > 0){
				if(!visitLog.recordVisitorGoingIn(dbOP, request))
					strErrMsg = visitLog.getErrMsg();
				else
					strErrMsg = "Visit log successfully recorded.";
			}
		}
	}
	else
		strErrMsg = "Visitor reference not found.";
%>

<body bgcolor="#D2AE72" topmargin="0">
<form name="form_" method="post" action="record_going_in.jsp">
<jsp:include page="./tabs.jsp?pgIndex=1"></jsp:include>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25" width="30%" align="center" bgcolor="#99CC99">
				<strong><font size="2" color="#FFFFFF">RECORD VISITOR'S GOING IN</font></strong></td>
			<td width="40%">&nbsp;</td>
		    <td width="30%" align="center" bgcolor="#99CC99">
				<strong><font size="2" color="#FFFFFF">Date and Time: <%=WI.getTodaysDateTime()%></font></strong></td>
		</tr>
	</table>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="2%" height="25">&nbsp;</td>
			<td width="98%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
		
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td width="50%" valign="top">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
					<tr>
						<td height="25">&nbsp;</td>
						<td colspan="3"><strong><u>Visitor's Info</u></strong></td>
					</tr>
					<tr>
					  	<td height="22" colspan="2">&nbsp;</td>
					  	<td>Last name:</td>
			  	        <td width="55%">
							<%
								if(vVisitorInfo != null && vVisitorInfo.size() > 0)
									strTemp = (String)vVisitorInfo.elementAt(3);
								else
									strTemp = "&nbsp;";
							%><%=strTemp%></td>
		  	        </tr>
					<tr>
					  	<td height="22" colspan="2">&nbsp;</td>
					  	<td>First name:</td>
			 	        <td>
							<%
								if(vVisitorInfo != null && vVisitorInfo.size() > 0)
									strTemp = (String)vVisitorInfo.elementAt(1);
								else
									strTemp = "&nbsp;";
							%><%=strTemp%></td>
		 	        </tr>
					<tr>
					  	<td height="22" colspan="2">&nbsp;</td>
					  	<td>Middle name: </td>
		                <td>
							<%
								if(vVisitorInfo != null && vVisitorInfo.size() > 0)
									strTemp = WI.getStrValue((String)vVisitorInfo.elementAt(2), "&nbsp;");
								else
									strTemp = "&nbsp;";
							%><%=strTemp%></td>
                  	</tr>
					<tr>
						<td colspan="4"><hr size="1"></td>
				  	</tr>
					<tr>
						<td height="25" colspan="2">&nbsp;</td>
					  	<td>IDs Presented: </td>
					  	<td>
							<select name="id_presented">
								<option value="">Select ID Presented</option>
								<%=dbOP.loadCombo("id_index", "id_type", " from visit_id_presented where is_valid = 1 order by id_type", WI.fillTextValue("id_presented"), false)%>
							</select>&nbsp;
							<%if(iAccessLevel > 1){%>
							<a href="javascript:UpdateIDs();"><img src="../../images/update.gif" border="0" /></a>
							<%}%></td>
				  	</tr>
					<tr>
					  <td height="25" colspan="2">&nbsp;</td>
					  <td>Identification Number </td>
					  <td>
					  <input name="id_card_number" type="text" size="32" value="<%=WI.fillTextValue("id_card_number")%>" class="textbox" maxlength="32"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
					  </td>
				  </tr>
					<tr>
					  	<td height="25" colspan="2">&nbsp;</td>
					  	<td>Visitor's Picture: </td>
					  	<td>
							<a href="javascript:UploadPicture('<%=strVisitorIndex%>')">
							<font color="#000000"><strong>UPLOAD PICTURE</strong></font></a></td>
				  	</tr>
					<tr>
					  	<td height="25" colspan="2">&nbsp;</td>
					 	<td>&nbsp;</td>
						<%
							if(vVisitorInfo != null && vVisitorInfo.size() > 0)
								strTemp = (String)vVisitorInfo.elementAt(0);
							else
								strTemp = "0";
							strTemp = "../../upload_img/visitor/"+strTemp+".jpg";
						%>
					  	<td rowspan="4"><img src="<%=strTemp%>" width="100" height="100" border="1"></td>
				  	</tr>
					<tr>
					  	<td height="25" colspan="2">&nbsp;</td>
					  	<td>&nbsp;</td>
				  	</tr>
					<tr>
					  	<td height="25" colspan="2">&nbsp;</td>
					  	<td>&nbsp;</td>
				  	</tr>
					<tr>
					  	<td height="25" colspan="2">&nbsp;</td>
					  	<td>&nbsp;</td>
				  	</tr>
					<tr>
					  	<td height="15" colspan="4">&nbsp;</td>
			  	  	</tr>
					<tr>
					  	<td height="25" colspan="2">&nbsp;</td>
				        <td>Visitor's RF Card No.</td>
		          	    <td>
							<input name="rf_card_num" type="text" size="32" value="<%=WI.fillTextValue("rf_card_num")%>" class="textbox" maxlength="32"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	          	    </tr>
					<tr>
						<td height="15" width="4%">&nbsp;</td>
						<td width="10%">&nbsp;</td>
						<td width="31%">Company Name </td>
						<td>
						<input name="company_name" type="text" size="32" value="<%=WI.fillTextValue("company_name")%>" class="textbox" maxlength="32"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">						</td>
					</tr>
					<tr>
					  <td height="15">&nbsp;</td>
					  <td>&nbsp;</td>
					  <td>Vehicle Type </td>
					  <td>
					  <input name="vehicle_type" type="text" size="32" value="<%=WI.fillTextValue("vehicle_type")%>" class="textbox" maxlength="32"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
					  </td>
				  </tr>
					<tr>
					  <td height="15">&nbsp;</td>
					  <td>&nbsp;</td>
					  <td>Vehicle Plate No.</td>
					  <td>
					  <input name="plate_no" type="text" size="32" value="<%=WI.fillTextValue("plate_no")%>" class="textbox" maxlength="32"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
					  </td>
				  </tr>
				</table>
			</td>
			<td width="50%" valign="top">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
					<tr>
					  	<td width="3%" height="25">&nbsp;</td>
				  	    <td colspan="4"><strong><u>Visitor's to Visit:</u></strong><br>
						<%
						String strVisitType = "1";
						strTemp = WI.fillTextValue("visit_type");
						if(strTemp.equals("1") || strTemp.length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";	
						%>
							<input type="radio" name="visit_type" value="1" <%=strErrMsg%> onClick="document.form_.submit()">Employee
						<%
						if(strTemp.equals("2")){
							strErrMsg = "checked";
							strVisitType = "2";
						}else
							strErrMsg = "";	
						%>
							<input type="radio" name="visit_type" value="2" <%=strErrMsg%> onClick="document.form_.submit()">Department
						<%
						if(strTemp.equals("3")){
							strErrMsg = "checked";
							strVisitType = "3";
						}else
							strErrMsg = "";	
						%>
							<input type="radio" name="visit_type" value="3" <%=strErrMsg%> onClick="document.form_.submit()">Event						</td>
			  	    </tr>
					<!--<tr>
					  	<td height="25">&nbsp;</td>
				  	    <td colspan="4"><strong><u>Visitor's Person to Visit:</u></strong></td>
			  	    </tr>-->
					<tr>
					  	<td height="15" colspan="5">&nbsp;</td>
			  	  	</tr>
					<%if(strVisitType.equals("1")){%>
					<tr>
					  	<td height="25">&nbsp;</td>
					  	<td width="29%">ID Number: </td>
				  	    <td colspan="3">
							<input name="emp_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
								onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName();" value="<%=WI.fillTextValue("emp_id")%>" size="16">&nbsp;							
							<a href="javascript:OpenSearch();"><img src="../../images/search.gif" border="0"></a>&nbsp;
							<label id="coa_info"></label></td>
			  	    </tr>
					<tr>
					  	<td height="15" colspan="5">&nbsp;</td>
				 	</tr>
					<tr>
						<td colspan="5">
							<table width="90%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
								<tr><td width="3%">&nbsp;</td>
									<%
										if(vStudInfo != null && vStudInfo.size() > 0)
											strTemp = (String)vStudInfo.elementAt(3);
										else
											strTemp = "&nbsp;";
									%>
									<td width="95%" height="25" class="thinborderALL">&nbsp;Last name: <%=strTemp%></td>
								</tr>
								<tr><td>&nbsp;</td>
									<%
										if(vStudInfo != null && vStudInfo.size() > 0)
											strTemp = (String)vStudInfo.elementAt(1);
										else
											strTemp = "&nbsp;";
									%>
									<td height="25" class="thinborderBOTTOMLEFTRIGHT">&nbsp;First name: <%=strTemp%></td>
								</tr>
								<tr><td>&nbsp;</td>
									<%
										if(vStudInfo != null && vStudInfo.size() > 0)
											strTemp = WI.getStrValue((String)vStudInfo.elementAt(14), "N/A");
										else
											strTemp = "&nbsp;";
									%>
									<td height="25" class="thinborderBOTTOMLEFTRIGHT">&nbsp;Department/Office: <%=strTemp%></td>
								</tr>
								<tr><td>&nbsp;</td>
									<%
										if(vStudInfo != null && vStudInfo.size() > 0)
											strTemp = WI.getStrValue((String)vStudInfo.elementAt(13), "N/A");
										else
											strTemp = "&nbsp;";
									%>
									<td height="25" class="thinborderBOTTOMLEFTRIGHT">&nbsp;College: <%=strTemp%></td>
								</tr>
							</table>						</td>														
			  	    </tr>	
					<%}else if(strVisitType.equals("2")){%>				
						<tr> 
            <td height="25">&nbsp;</td>
            <td height="25" valign="bottom">College</td>
            <td width="68%" height="25"><select name="c_index" onChange="loadDept();" style="width:300px;">
                <option value="0">N/A</option>
<% 
	strTemp = WI.fillTextValue("c_index");	
%>           <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select>			</td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" valign="bottom">Office/Department</td>
            <td height="25"> 
			 <label id="load_dept" style="position:absolute; width:200px;">
			 <select name="d_index" style="width:200px;">
			 <option >N/A</option>
<%
strErrMsg = WI.fillTextValue("d_index");		
if (strTemp == null || strTemp.length() == 0 || strTemp.compareTo("0") == 0) strTemp = " and (c_index = 0 or c_index is null) ";
	else strTemp = " and c_index = " +  strTemp;
%>
               <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 " + strTemp + " order by d_name asc",strErrMsg, false)%> </select>
			  </label>
              &nbsp; </td>
          </tr>
						
					
			<%}else{%>
				<tr>
					<td>&nbsp;</td>
					<td>Event Name:</td>
					<td>
						<select name="event_index" style="width:250px;">
							<option value=""></option>
							<%=dbOP.loadCombo("EVENT_INDEX", "EVENT_NAME, VENUE", " from visit_event where is_valid = 1  "+
								" and ( valid_date_from = '"+WI.getTodaysDate()+"' or valid_date_to >= '"+WI.getTodaysDate()+"')  order by event_name ", 
								WI.fillTextValue("event_index"),false)%>							
						</select>	
						
						&nbsp; &nbsp;	
						<a href="javascript:UpdateEvent();"><img src="../../images/update.gif" border="0"></a>		
					</td>
				</tr>			
			
			
			<%}%>
					<tr>
					  	<td height="15" colspan="5">&nbsp;</td>
			  	  	</tr>
					<tr>
					  	<td height="25">&nbsp;</td>
			  	  	    <td colspan="4"><strong><u>Purpose: </u></strong></td>
		  	  	    </tr>
					<tr>
					  	<td>&nbsp;</td>
				  	    <td colspan="4">
							<textarea name="purpose" cols="40" rows="4" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
								onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("purpose")%></textarea></td>
			  	    </tr>
					<tr>
						<td height="15" colspan="5">&nbsp;</td>
					</tr>
					<tr>
					  	<td height="25">&nbsp;</td>
					  	<td colspan="4">
						<%if(iAccessLevel > 1){%>
							<a href="javascript:SaveRecord();"><img src="../../images/save.gif" border="0"></a>
								<font size="1">Click to save record information.</font>
							<a href="javascript:CancelOperation();"><img src="../../images/cancel.gif" border="0"></a>
								<font size="1">Click to refresh page.</font>
						<%}else{%>
							Not authorized to save record information.
						<%}%>						</td>
				  	</tr>
				</table>
			</td>
		</tr>
	</table>

	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="save_record">
	<input type="hidden" name="info_index" value="<%=strVisitorIndex%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>