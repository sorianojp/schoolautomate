<%@ page language="java" import="utility.*, java.util.Vector" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Welcome to Information Kiosk</title>
<style>
body{background:#FFFFFF url(img/bg1.png) repeat-x; margin:0px}
.font1{font-family:Arial, Helvetica, sans-serif; font-size:310%; color:#0066CC; font-weight:bold}
.font2{font-family:Arial, Helvetica, sans-serif; font-size:160%; color:#0066CC; font-weight:normal}
.font3{font-family:Arial, Helvetica, sans-serif; font-size:80%; color:#0066CC; font-weight:normal}
.font4{font-family:Arial, Helvetica, sans-serif; font-size:35%; color:#0066CC; 
       font-weight:normal; padding-top:50px; color: #666666}
.font5{font-family:Arial, Helvetica, sans-serif; font-size:210%; color:#0066CC; font-weight:bold}
.container{position:relative; margin-left:auto; margin-right:auto}
</style>
</head>
<script language="javascript">
function pageForward(strLoc) {
	alert("I am here.. to page forward.");
	if(strLoc == '1') {
		location = "../ess/ess_index.htm";
	}
	else
		location = "../my_home/my_home_index.htm";
}
</script>

<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	
	try
	{
		dbOP = new DBOperation();
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
	String strSchoolName = null;
	String strSchCode    = null;
	String strErrMsg     = null;
	
	String strIDNumber   = null;
	String strUserIndex  = null;
	
	boolean bolIsSchool  = true;
	
	
	String strSQLQuery = "select school_name, school_index from sys_info";
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()) {
		strSchoolName = rs.getString(1);
		strSchCode   = rs.getString(2);
	}
	rs.close();
	
	//get if it is school. 
	strSQLQuery = "select prop_val from read_property_file where prop_name = 'is_school'";
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strSQLQuery != null && strSQLQuery.equals("0"))
		bolIsSchool = false;
	
	boolean bolIsLoggedIn = false;
	int iPageForward = 0;
	boolean bolPageRefresh = false;
	
	if(WI.fillTextValue("i_").length() > 0) {
		if(session.getAttribute("in_") != null) {
			//previous information still there.. 
			session.removeAttribute("id_");
			
			session.removeAttribute("in_"); //index
    	    session.removeAttribute("s_f_"); //sy_from
        	session.removeAttribute("s_t_"); //sy_to
	        session.removeAttribute("s_"); //semester
    	    session.removeAttribute("y_"); //year_level
        	session.removeAttribute("d_t_"); //course_degree_type
	        session.removeAttribute("c_h_i"); //curriculum_hist_index
    	    session.removeAttribute("c_i"); //course_index
		}
	
		String strUserID = WI.fillTextValue("i_");
      	String strTime = WI.fillTextValue("t_");
      	String strMD5 = WI.fillTextValue("m");

		if(strUserID.length() == 0 || strTime.length() == 0 || strMD5.length() == 0)
        	strErrMsg = "Failed to authenticate. Please login again.";
		else {
			strSQLQuery = "select id_ from KIOSK_SESSION where ID_='" + strUserID +
        		"' and TIME_='" + strTime + "' and MD5='" + strMD5 + "'";
      		strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
      		if(strSQLQuery == null) {
       			strErrMsg = "Failed to authenticate request. Please login again.";
      		}
		}
		if(strErrMsg == null) {
			String strAuthTypeIndex = null;
			strSQLQuery = "select auth_type_index, id_number, user_index from user_table where id_number = '"+strUserID+"' or barcode_id ='"+
							strUserID+"'";
			rs = dbOP.executeQuery(strSQLQuery);
			if(rs.next()) {
				strAuthTypeIndex = WI.getStrValue(rs.getString(1), "2");	
				strIDNumber      = rs.getString(2);
				strUserIndex     = rs.getString(3);
			}
			rs.close();
			if(strAuthTypeIndex == null)
				strErrMsg = "Error in getting user information.";
			else {
				if(WI.getStrValue(strAuthTypeIndex).equals("4"))
					iPageForward = 1;//student/
				else	
					iPageForward = 2;//faculty.
			}
		}
	} 
	else {
		if(session.getAttribute("in_") != null) {
			session.removeAttribute("in_"); //index
    	    session.removeAttribute("s_f_"); //sy_from
        	session.removeAttribute("s_t_"); //sy_to
	        session.removeAttribute("s_"); //semester
    	    session.removeAttribute("y_"); //year_level
        	session.removeAttribute("d_t_"); //course_degree_type
	        session.removeAttribute("c_h_i"); //curriculum_hist_index
    	    session.removeAttribute("c_i"); //course_index
			session.invalidate();
		}
	}
	
if(dbOP != null)
	dbOP.cleanUP();
//System.out.println("strIDNumber : "+strIDNumber);
if(iPageForward == 1) {%>
	<jsp:forward page="./student.jsp"/>
<%}else if(iPageForward == 2) {%>
		<jsp:forward page="employee.jsp"/>
<%}%>

<body>
<center>
<%if(strErrMsg != null) {%>
	<p align="center" style="font-weight:bold; font-size:14px; color:#FF0000; font-family:Verdana, Arial, Helvetica, sans-serif"><%=strErrMsg%></p>
<%}%>
<table width="100%" height="100%" cellpadding="0" cellspacing="0" border="0" align="center">
  <!--DWLayoutTable-->
<tr>
<td align="center" valign="middle" class="font5">
<img src="../images/logo/<%=strSchCode%>.gif" width="200px" height="200px" align="absmiddle"/> <%=strSchoolName%></td>
</tr>
<tr>
<td height="90" align="center" valign="middle">
<img src="img/screenshot-web-information-kiosk-pic1.png" width="750" height="113" /></td>
</tr>
<tr>
<td colspan="3" align="center" valign="middle" class="font1">Welcome to Information Kiosk<br/>
  <span class="font4"><br/>
  Direction:<br/>
  Swipe I.D. on the RF Reader or<br/>
  Enter I.D. using keypad<br />&nbsp;</span></td>
</tr>
<tr>
<td height="19" colspan="5" align="center" valign="middle" class="font2">
<script type="text/javascript">
tday  =new Array("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday");
tmonth=new Array("January","February","March","April","May","June","July","August","September","October","November","December");

function GetClock(){
d = new Date();
nday   = d.getDay();
nmonth = d.getMonth();
ndate  = d.getDate();
nyear = d.getYear();
nhour  = d.getHours();
nmin   = d.getMinutes();
nsec   = d.getSeconds();

if(nyear<1000) nyear=nyear+1900;

     if(nhour ==  0) {ap = " AM";nhour = 12;} 
else if(nhour <= 11) {ap = " AM";} 
else if(nhour == 12) {ap = " PM";} 
else if(nhour >= 13) {ap = " PM";nhour -= 12;}

if(nmin <= 9) {nmin = "0" +nmin;}
if(nsec <= 9) {nsec = "0" +nsec;}


document.getElementById('clockbox').innerHTML=""+tday[nday]+", "+tmonth[nmonth]+" "+ndate+", "+nyear+" "+nhour+":"+nmin+":"+nsec+ap+"";
setTimeout("GetClock()", 1000);
}
window.onload=GetClock;
</script>
<div id="clockbox"></div></td>
</tr>
</table>
</center>
</body>
</html>