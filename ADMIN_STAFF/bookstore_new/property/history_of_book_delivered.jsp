<%@ page language="java" import="utility.*, citbookstore.BookRequest,citbookstore.BookManagement,java.util.Vector,java.util.Date"%>
<%
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	boolean bolIsCIT = strSchCode.startsWith("CIT");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>List of Approved Books</title></head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">

	function loadClassification() {	
		var objCOA=document.getElementById("load_classification");
		var header = "All";
		var selName = "classification";
		var onChange = "";
		var tableName = "bed_level_info";
		var fields = "g_level,level_name";
		var headerValue = "";
		
		var vCondition = '';
		var vClassValue = document.form_.book_catg.value;
		if(vClassValue.length == 0)
			vCondition = ' where edu_level@0';
		else{
			if(vClassValue == '1')
				vCondition = '';
			else//if college
				vCondition = ' where edu_level@0';
		}
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=20400&query_con="+vCondition+"&onchange="+onChange+"&sel_name="+selName+"&table_name="+tableName+"&fields="+fields+"&header="+header+"&header_value="+headerValue;
	
		this.processRequest(strURL);
	}		
	
	function ViewHistory(){
		document.form_.view_history_.value = '1';
		document.form_.submit();
	}
	
	function PrintPg(){
	var pgLoc = "";
		<%if(WI.fillTextValue("date_type").equals("2")){%>
		pgLoc = "./print_delivered_history.jsp?date_type="+document.form_.date_type.value+"&date_fr="+document.form_.date_fr.value+
			"&date_to="+document.form_.date_to.value+"&book_catg="+document.form_.book_catg.value+"&classification="+document.form_.classification.value+
			"&view_all=1&view_history_=1&delivered_accepted_=1";
		<%}else{%>
		pgLoc = "./print_delivered_history.jsp?date_type="+document.form_.date_type.value+"&date_fr="+document.form_.date_fr.value+
			"&book_catg="+document.form_.book_catg.value+"&classification="+document.form_.classification.value+
			"&view_all=1&view_history_=1&delivered_accepted_=1";
		<%}%>
						
		var win=window.open(pgLoc,"PrintPg",'width=1000,height=550,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-PROPERTY","history_of_book_delivered.jsp");
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
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE-PROPERTY"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../../../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		if(iAccessLevel == 0){
			response.sendRedirect("../../../commfile/unauthorized_page.jsp");
			return;
		}
	}
	//end of security
	
	
	int iSearchResult = 0;
	Vector vRetResult = new Vector();	
	BookRequest br = new BookRequest();	
			
	if(WI.fillTextValue("view_history_").equals("1")){
		vRetResult = br.viewDeliveredItems(dbOP, request);
		if(vRetResult == null)
			strErrMsg = br.getErrMsg();
		else
			iSearchResult = br.getSearchCount();
	}
	
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./history_of_book_delivered.jsp"  method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable1">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: PROPERTY REQUEST MONITORING - HISTORY OF BOOKS DELIVERED ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable2">		
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Delivery Date: </td>
			<td width="80%">
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("date_type"), "1");
				%>
				<select name="date_type" onchange="document.form_.submit();">
                  	<%if (strTemp.equals("1")){%>
					<option value="1" selected>Specific Date</option>
                  	<%}else{%>
                  	<option value="1">Specific Date</option>
                  	<%}if (strTemp.equals("2")){%>
                  	<option value="2" selected>Date Range</option>
                  	<%}else{%>
                  	<option value="2">Date Range</option>
                  	<%}%>
                </select>
				<input name="date_fr" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" border="0"></a>
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("date_type"), "1");
					if(strTemp.equals("2")){
				%>
				to 
				<input name="date_to" type="text" size="10" maxlength="10" readonly="yes" class="textbox" 
					value="<%=WI.fillTextValue("date_to")%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" border="0"></a>
				<%}%></td>
		</tr>
		
		
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Book Category :</td>
			<%	
			String strCatg = WI.fillTextValue("book_catg");				
			%>
			
			<td><select name="book_catg" onChange="loadClassification();">
					<option value="">Select Book Category</option>
          			<%=dbOP.loadCombo("catg_index","catg_name", " from bs_book_catg where is_valid = 1 order by catg_name ", strCatg, false)%>
        		</select></td>
		</tr>
		
		
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Grade Level :</td>
			<%			
				strTemp = WI.fillTextValue("classification");			
				if(strCatg.length() == 0 || strCatg.equals("0") || strCatg.equals("2"))//college or not selected
					strErrMsg = " where edu_level = 0 ";
				else
					strErrMsg = "";
			%>
			<td><label id="load_classification">
				<select name="classification">	
					<option value="">All</option>
					<%=dbOP.loadCombo("g_level","level_name", " from bed_level_info "+strErrMsg, strTemp, false)%> 
				</select>
				</label></td>
		</tr>
		
		
		
		
		
		
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td>
				<a href="javascript:ViewHistory();"><img src="../../../images/form_proceed.gif" border="0" /></a>
				<font size="1">Click to view history.</font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>

<%if(vRetResult != null && vRetResult.size() >0){%>
		<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="" id="myTable3">
			<tr><td align="right" ><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0" /></a>
			<font size="1">Click to print books items</font>
			</td></tr>
			<tr><td height="15">&nbsp;</td></tr>
		</table>
		
		<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="">
			<tr><td height="20" colspan="10" class="">
				<div align="center"><strong>
				<font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font>
				</strong>
				<%if(bolIsCIT){%>
				<br />INSTRUCTIONAL MATERIALS DISTRIBUTION CENTER<br /><br />
				<%}%>
				</div></td></tr>
			<tr><td height="20" bgcolor="" colspan="10" class=""><div align="center"><strong>HISTORY OF BOOKS DELIVERED</strong></div></td></tr>			
		</table>
		
		
		<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder" id="myTable4">
			
			<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="4">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(br.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="5"> &nbsp;
			<%
				int iPageCount = 1;				
				iPageCount = iSearchResult/br.defSearchSize;		
				if(iSearchResult % br.defSearchSize > 0)
					++iPageCount;				
				strTemp = " - Showing("+br.getDisplayRange()+")";
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="document.form_.view_history_.value='1';document.form_.submit();">
					<%
						strTemp = WI.fillTextValue("jumpto");
						if(strTemp == null || strTemp.trim().length() ==0)
							strTemp = "0";
						int i = Integer.parseInt(strTemp);
						if(i > iPageCount)
							strTemp = Integer.toString(--i);
			
						for(i = 1; i<= iPageCount; ++i ){
							if(i == Integer.parseInt(strTemp) ){%>
								<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}else{%>
								<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}
						}%>
					</select></div>
				<%}%> </td>
		</tr>
			
			
			
			
			<tr>
				<td width="5%"  align="center" height="25" class="thinborder"><strong>Count</strong></td>
				<td width="18%" align="center" class="thinborder"><strong>Title</strong></td>
				<td width="13%" align="center" class="thinborder"><strong>Author</strong></td>
				<td width="14%" align="center" class="thinborder"><strong>Publisher</strong></td>				
				<td width="5%" align="center" class="thinborder"><strong>Qty</strong></td>								
				<td width="10%" align="center" class="thinborder"><strong>Approved By</strong></td>
				<td width="10%" align="center" class="thinborder"><strong>Approved Date</strong></td>	
				<td width="10%" align="center" class="thinborder"><strong>Delivered Date</strong></td>	
				<td width="15%" align="center" class="thinborder"><strong>Delivered To</strong></td>			
			</tr>
			
			<%
			int iCount=1;
			for(int i=0;i<vRetResult.size();i+=22,iCount++){%>
			<tr>	
				<td align="center" height="25" class="thinborder"><%=iCount%></td>
				<td align="" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
				<td align="" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+3),"N/A")%></td>
				<td align="" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+5),"N/A")%></td>				
				<td align="" class="thinborder"><%=(String)vRetResult.elementAt(i+6)%></td>												
				<td align="" class="thinborder">
					<%=WebInterface.formatName((String)vRetResult.elementAt(i+8),(String)vRetResult.elementAt(i+9),(String)vRetResult.elementAt(i+10),4)%>
				</td>
														
				<td align="" class="thinborder"><%=(String)vRetResult.elementAt(i+11)%></td>
				<td align="" class="thinborder"><%=(String)vRetResult.elementAt(i+21)%></td>
				
				<td align="" class="thinborder">
					<%=WI.getStrValue((String)vRetResult.elementAt(i+13))%>
					<%=WI.getStrValue((String)vRetResult.elementAt(i+14),"/ ","","")%>
					<%=WI.getStrValue((String)vRetResult.elementAt(i+16),"/ ","","")%>
					
				</td>	
				
			</tr>
			<%}%>					
		</table>
		
<%}//end of vRetResult!=null%>



	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="close_wnd_called" value="0">
	<input type="hidden" name="donot_call_close_wnd"  />
	<input type="hidden" name="view_history_" />
	<input type="hidden" name="delivered_accepted_"  value="1"/>	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
